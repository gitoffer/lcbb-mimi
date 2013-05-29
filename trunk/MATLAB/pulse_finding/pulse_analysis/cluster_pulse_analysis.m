
% ID = kmeans_c5_cosine(:,1);
% labels2 = kmeans_c5_cosine(:,2) + 1;

X = cat(1,fits.corrected_area_norm);
X( isnan(X) ) = 0;

% X = standardize_matrix(X, 2);

Niter = 1000;
labels_all = nan( Niter, size(X,1) );

for i = 1:Niter
    
    [~,U] = fcm(X,10);
    [~,labels_all(i,:)] = max(U);
    
end

RI = zeros(Niter);

for i = 1:Niter
    for j = 1:Niter
        RI(i,j) = rand_index( labels_all(i,:), labels_all(j,:) );
    end
end

%% FCM

X = cat(1,fits.corrected_area_norm);
X = bsxfun(@rdivide, X, nanstd(X,[],2) );

X( isnan(X) ) = 0;

num_clusters = 8;

[center,U,obj] = fcm(X,num_clusters); [max_prob,labels] = max(U);

% labels = labels_all(1,:);

for i = 1:numel(labels)
    
    this_fit = fits.get_fitID( fits(i).fitID );
    this_fit.cluster_label = labels(i);
    this_fit.cluster_weight = max_prob(i);
    fits = fits.set_fitID( fits(i).fitID, this_fit );
    
end

fits_wt = fits.get_embryoID( 1:5 );
fits_twist = fits.get_embryoID( 6:7 );
fits_cta = fits.get_embryoID( 8:10 );

%%

clear cluster*
for i = 1:num_clusters
    
    eval(['cluster' num2str(i) ' = fits([fits.cluster_label] == ' num2str(i) ');']);
    eval(['cluster' num2str(i) '_wt = fits_wt([fits_wt.cluster_label] == ' num2str(i) ');']);
    eval(['cluster' num2str(i) '_cta = fits_cta([fits_cta.cluster_label] == ' num2str(i) ');']);
    eval(['cluster' num2str(i) '_twist = fits_twist([fits_twist.cluster_label] == ' num2str(i) ');']);
    
    eval([ 'cluster' num2str(i) '.plot_heatmap']);
    
end

%%

fits_cta = fits.get_embryoID( 8 );

[N_const,bins] = hist([fits_cta( c8([fits_cta.cellID]) == 1 ).cluster_label],1:num_clusters);
[N_exp,bins] = hist([fits_cta( c8([fits_cta.cellID]) == 2 ).cluster_label],1:num_clusters);

figure
subplot(2,num_clusters,1:num_clusters)

[N_wt] = hist( [fits_wt.cluster_label], 1:num_clusters);
[N_twist] = hist( [fits_twist.cluster_label], 1:num_clusters);
[N_cta] = hist( [fits_cta.cluster_label], 1:num_clusters);
bar(1:num_clusters, ...
    cat(1,N_wt/sum(N_wt),N_twist/sum(N_twist),N_cta/sum(N_cta))','grouped'),legend('Wild-type','twist','cta')
% bar(bins,cat(1,N_const/sum(N_const),N_exp/sum(N_exp))','grouped'),legend('Constricting','Expanding')
ylabel('Probability')

colors = {'b','c','y','r','g'};
for i = 1:num_clusters
    
    subplot(2,num_clusters,num_clusters+i);
    
    eval(['cluster_area = cat(1,cluster' num2str(i) '.corrected_area_norm);']);
%     cluster_area = bsxfun(@rdivide,cluster_area,nanstd(cluster_area,[],2));
    eval(['weights = cat(1,cluster' num2str(i) '.cluster_weight);']);
    shadedErrorBar( fits(1).corrected_time, ...
        nanwmean(cluster_area,weights), nanstd(cluster_area) , colors{i});
    
end

