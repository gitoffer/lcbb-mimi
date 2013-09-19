% cluster_validate,m

standardized_area_norm = standardize_matrix(cat(1,fits.corrected_area_norm),2);
data2cluster = standardized_area_norm;
data2cluster( isnan(data2cluster ) ) = 0;

% distmat_pear = squareform( pdist( standardized_area_norm, @nan_eucdist ));
num_clusters = 1:20;
opts = [2, 1000, 1e-5, 0];

%% Initialize

labels_all = nan( numel(fits), numel(num_clusters) );

% Pseudo-color the inter + intra cluster distances
for i = 1:numel(num_clusters)
    
    % FCM
    [~,U,obj] = fcm( data2cluster,num_clusters(i), opts);
    [~,labels_all(:,i)] = max(U);
    [~,num_members,cluster_names] = get_cluster_numbers(labels_all(:,i));
    
    % Get matrix display
    [sorted_labels,cluster_order] = sort(labels_all(:,i));
    foo = distmat(cluster_order,cluster_order);
    % replace lower triangle with label matrix
    label_mat = make_matrix_block_lines(sorted_labels,'l');
    foo(logical( tril(ones( numel(fits)) ) )) = ...
        label_mat( logical(tril( ones(numel(fits))) ) );
    % delete diagonal terms
    foo(logical(eye( numel(fits) ))) = NaN;
    
    % Plot
    figure
    pcolor(foo'); shading flat; colorbar; axis tight;
    % Set up correct ticks and ticklabels
    set(gca,'Xtick',unique(cumsum(num_members+1) - floor(num_members/2)), 'Xticklabel', cluster_names);
    set(gca,'Ytick',unique(cumsum(num_members+1) - floor(num_members/2)), 'Yticklabel', cluster_names);
    title('Distances between cluster members');
    
end
%% Average distance between cluster members
for i = 1:numel(num_clusters)
    % Get FCM labels
    [~,num_members,cluster_names] = get_cluster_numbers(labels(:,i));
    [sorted_labels,cluster_order] = sort(labels_all(:,i));
    
    Dc = get_cluster_distances(distmat,sorted_labels);
    
    figure
    imagesc(Dc),colorbar,shading flat,axis equal,axis xy tight
    xlabel('Clusters'),ylabel('Clusters')
    title('Average distance between cluster members')
    
end
%% Bootstrap and test for average distances
% Select between inter-cluster or intra-cluster distances
type = 'intra';
nboot = 100;

J = zeros(1,numel(num_clusters));
for i = 1:numel(num_clusters)
    
    [~,U,obj] = fcm( data2cluster,num_clusters(i), opts);
    [~,labels] = max(U);
    
    J(i) = min(obj);
    
    % Load FMC labels
    [~,num_members,cluster_names] = get_cluster_numbers(labels);
    [sorted_labels,cluster_order] = sort(labels);
    
    Dc = get_cluster_distances(distmat,sorted_labels);
    % Construct @BOOTFUN
    switch type
        case 'intra'
            bootfun = @(labels) diag(get_cluster_distances(distmat,labels));
            original_stat = diag(Dc);
        case 'inter'
            bootfun = @(labels) ...
                logical_indexing_fun( ...
                get_cluster_distances( distmat,labels_all(:,i) ), ...
                logical(~eye(num_clusters)) );
            original_stat = Dc( logical(~eye(num_clusters)) );
        otherwise, error('Unknown TYPE of distance.');
    end
    % Use BOOTSTRP.m
    bootstat = bootstrp(nboot,bootfun,sorted_labels);
    
    % Construct boxplot of original stat and bootstrap results
    [X,G] = make_boxplot_args(original_stat,bootstat);
    [G{strcmpi(G,'1')}] = deal('Original clusters');
    [G{strcmpi(G,'2')}] = deal('Bootstrapped clusters');
%     figure,
    boxplot(X,G);
    title(['Average ' type '-cluster distances, k = ' num2str( num_clusters(i))])
    drawnow;
    
    % Calculate an intra-cluster distance average
    real_intra(i) = nanmean(diag(Dc));
    real_intra_std(i) = nanstd(diag(Dc));
    boot_intra(i) = nanmean(bootstat(:));
    boot_intra_std(i) = nanstd(bootstat(:));
    
    display(['Finished with k=' num2str( num_clusters(i) )]);
end
%% Get jump-distortion

Niter = 100;
Dk = zeros(Niter,numel(num_clusters) + 1);
for n = 1:Niter
    for i = 1:numel(num_clusters)
        
        if i > 1
            %Perform FCM clustering
            [~,U] = fcm( data2cluster, num_clusters(i), opts);
            %         [labels] = kmeans( data2cluster,num_clusters(i));
            [~,labels] = max(U);
        else
            labels = ones(1,numel(fits));
        end
        Dk( n, i+1 ) = distortion(data2cluster,labels);
        
    end
    display(['Finished with N = ' num2str(n)]);
    
end

% Compensate for asymptonic form of distortion-rate curve for Gaussians
transformed_distortion = Dk.^(-size(data2cluster,2)/2);
transformed_distortion(:,1) = 0;
jump_distort = diff( transformed_distortion' );
