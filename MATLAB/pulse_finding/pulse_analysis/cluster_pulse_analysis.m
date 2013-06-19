
for k = 3:7
    
    X = cat(1,fits.corrected_area_norm);
    X( isnan(X) ) = 0;
    
    % X = standardize_matrix(X, 2);
    
    Niter = 100;
    labels_all = nan( Niter, size(X,1) );
    
    for i = 1:Niter
        
        [~,U] = fcm(X,10,opts);
        [~,labels_all(i,:)] = max(U);
        
    end
    
    RI = zeros(Niter);
    
    for i = 1:Niter
        for j = 1:Niter
            RI(i,j) = rand_index( labels_all(i,:), labels_all(j,:) );
        end
    end
    
    avgRI(k-2) = mean(RI(:));
    stdRI(k-2) = std(RI(:));

end

%% FCM

X = cat(1,fits.corrected_area_norm);
X = bsxfun(@rdivide, X, nanstd(X,[],2) );

X( isnan(X) ) = 0;

num_clusters = 5;

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
    
    eval(['cluster' num2str(i) ' = fits([fits.cluster_label] == ' num2str(order(i)) ');']);
    eval(['cluster' num2str(i) '_wt = fits_wt([fits_wt.cluster_label] == ' num2str(order(i)) ');']);
    eval(['cluster' num2str(i) '_cta = fits_cta([fits_cta.cluster_label] == ' num2str(order(i)) ');']);
    eval(['cluster' num2str(i) '_twist = fits_twist([fits_twist.cluster_label] == ' num2str(order(i)) ');']);
    
    eval([ 'cluster' num2str(i) '.plot_heatmap']);
%     figure
%     eval(['pcolor(cat(1, cluster' num2str(i) '.weight_sort.corrected_area_norm ));']);
%     title(['Cluster ' num2str(i) ])
%     shading flat, caxis([-10 10]),colorbar
    
end
order = [5 3 1 4 2];
revorder = reverse_index(order);
entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};

%%

figure

fits_cta = fits.get_embryoID( 8 );
[N_const,bins] = hist(revorder([fits_cta( c8([fits_cta.cellID]) == 1 ).cluster_label]), ...
    1:num_clusters);
[N_exp,bins] = hist(revorder([fits_cta( c8([fits_cta.cellID]) == 2 ).cluster_label]), ...
    1:num_clusters);

[N_wt] = hist( [fits_wt.cluster_label], 1:num_clusters);
[N_twist] = hist( [fits_twist.cluster_label], 1:num_clusters);
[N_cta] = hist( [fits_cta.cluster_label], 1:num_clusters);

N_wt = N_wt(order);
N_twist = N_twist(order);
N_cta = N_cta(order);

bar(1:3, ...
    cat(1,N_wt/sum(N_wt),N_twist/sum(N_twist),N_cta/sum(N_cta)),'stacked')
set(gca,'XTickLabel',{'Wild-type','twist','cta'});
% bar(1:2,cat(1,N_const/sum(N_const),N_exp/sum(N_exp)),'stacked')
% set(gca,'XTickLabel',{'Constricting','Expanding'})
ylabel('Probability')
legend(entries{:});


%%

figure

colors = {'b','c','g','r','m'};
for i = 1:num_clusters
    
    eval(['this_cluster = cluster' num2str(i) '_wt.weight_sort;']);
    cluster_area = cat(1,this_cluster.corrected_area_norm);
    
    subplot(2,num_clusters,i);
    [X,Y] = meshgrid( fits(1).corrected_time,1:numel(this_cluster) );
    pcolor( X,Y, cluster_area );
    shading flat, caxis([-10 10]),colorbar;
        title(['Cluster ' num2str(order(i)) ]);
    xlabel('Pulse time (sec)')
    
    subplot(2,num_clusters,i+num_clusters);
    weights = cat(1, this_cluster.cluster_weight);
    shadedErrorBar( fits(1).corrected_time, ...
        nanwmean(cluster_area,weights), nanstd(cluster_area) , colors{i});
    set(gca,'XTick',[-40 0 40]);
    
end


