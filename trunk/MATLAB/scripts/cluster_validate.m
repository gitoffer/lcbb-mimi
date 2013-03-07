% cluster_validate,m

dist_mat = D;
dist_name = 'Pearson distance';
folder = '_pearson';
%% Template matching

[R2,res,templates] = get_cluster_residuals(standardized_area_norm,cluster_labels);

%% Pseudo-color the inter + intra cluster distances
for i = 5:10
    cluster_dir = ['~/Desktop/Clustering results/corrected_area_norm_nonan/c' num2str(i) folder '/'];
    name = [cluster_dir 'kmeans_c' num2str(i) folder '.txt'];
    % Load clsuter
    [cluster_order,cluster_labels,cluster_labels_ordered,pulse] = load_gedas_fun(name,pulse);
    [num_clusters,num_members,cluster_names] = get_cluster_numbers(cluster_labels);
    
    foo = dist_mat(cluster_order,cluster_order);
    % replace lower triangle with label matrix
    label_mat = make_matrix_block_lines(cluster_labels,'l');
    foo(logical(tril(ones(num_peaks)))) = label_mat(logical(tril(ones(num_peaks))));
    % delete diagonal terms
    foo(logical(eye(num_peaks))) = NaN;
    pcolor(foo); shading flat; colorbar; axis tight;
    drawnow
    % Set up correct ticks and ticklabels
    set(gca,'Xtick',unique(cumsum(num_members+1) - floor(num_members/2)), 'Xticklabel', cluster_names);
    set(gca,'Ytick',unique(cumsum(num_members+1) - floor(num_members/2)), 'Yticklabel', cluster_names);
    title('Distances between cluster members');
    saveas(gcf,[cluster_dir 'cluster_distances'],'fig');
end
%% Average distance between cluster members
for i = 5:10
    cluster_dir = ['~/Desktop/Clustering results/corrected_area_norm_nonan/c' num2str(i) folder '/'];
    name = [cluster_dir 'kmeans_c' num2str(i) folder '.txt'];
    % Load clsuter
    [cluster_order,cluster_labels,cluster_labels_ordered,pulse] = load_gedas_fun(name,pulse);
    [num_clusters,num_members,cluster_names] = get_cluster_numbers(cluster_labels);
    
    Dc = get_cluster_distances(dist_mat,cluster_labels_ordered);
    imagesc(Dc),colorbar,shading flat,axis equal,axis xy tight
    xlabel('Clusters'),ylabel('Clusters')
    title('Average distance between cluster members')
    drawnow;
    saveas(gcf,[cluster_dir 'average_cluster_distances'],'fig')
end
%% Bootstrap and test for average distances
% Select between inter-cluster or intra-cluster distances
type = 'intra';
nboot = 1000;

for i = 5:10
    
    % Construct file name
    cluster_dir = ['~/Desktop/Clustering results/corrected_area_norm_nonan/c' num2str(i) folder '/'];
    name = [cluster_dir 'kmeans_c' num2str(i) folder '.txt'];
    % Load clsuter
    [cluster_order,cluster_labels,cluster_labels_ordered,pulse] = load_gedas_fun(name,pulse);
    [num_clusters,num_members,cluster_names] = get_cluster_numbers(cluster_labels);
    
    Dc = get_cluster_distances(dist_mat,cluster_labels_ordered);
    switch type
        case 'intra'
            bootfun = @(labels) diag(get_cluster_distances(dist_mat,labels));
            original_stat = diag(Dc);
        case 'inter'
            bootfun = @(labels) ...
                logical_indexing_fun( ...
                get_cluster_distances(dist_mat,labels), ...
                logical(~eye(num_clusters)));
            original_stat = Dc(logical(~eye(num_clusters)));
        otherwise, error('Unknown TYPE of distance.');
    end
    
    bootstat = bootstrp(nboot,bootfun,cluster_labels_ordered);
%     Construct boxplot
    
    [X,G] = make_boxplot_args(original_stat,bootstat);
    [G{strcmpi(G,'1')}] = deal('Original clusters');
    [G{strcmpi(G,'2')}] = deal('Bootstrapped clusters');
    boxplot(X,G);
    title(['Average ' type '-cluster distances'])
    drawnow;
    saveas(gcf,[cluster_dir 'bootstrap_' type 'cluster_dist'],'fig');
    
%     Calculate an intra-cluster distance average
    avg_intra(i-1) = nanmean(diag(Dc));
    boot_intra(i-1) = nanmean(bootstat(:));
    boot_intra_std(i-1) = nanstd(bootstat(:));
    
    display(['Finished with k=' num2str(i)]);
end
%% Get residual/p2 norms
index = 0;
for i = 2:10
    % Get correct name
    cluster_dir = ['~/Desktop/Clustering results/corrected_area_norm_notail/c' num2str(i) '_pearson/'];
    name = [cluster_dir 'kmeans_c' num2str(i) '_pearson.txt'];
    % Load clsuter
    [cluster_order,cluster_labels,cluster_labels_ordered,pulse] = load_gedas_fun(name,pulse);
    
    % Get goodness of fit
    Dc = get_cluster_distances(dist_mat,cluster_labels_ordered);
    [R2,~,~] = get_cluster_residuals(standardized_area_norm,cluster_labels,@nanmean);
    
    index = index + 1;
    avg_intra_dist(index) = mean(diag(Dc));
    avg_R2(index) = mean(R2);
    std_R2(index) = std(R2);
end

figure,
plot(2:10,avg_intra_dist)
xlabel('Number of clusters');
ylabel(['Average intra_cluster ' dist_name]);
title(['Kmeans with varying k ' dist_name]);

figure,
errorbar(2:10,avg_R2,std_R2)
xlabel('Number of clusters');
ylabel('Average residual');
title(['Kmeans with varying k ' dist_name]);