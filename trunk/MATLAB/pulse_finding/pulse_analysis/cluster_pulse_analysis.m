%% Stability analysis of FCM clustering

o = [2 100 1e-5 0];

for k = 2:10
    
    filtered = fits( cellfun(@(x) numel(x(isnan(x))), {fits.corrected_area_norm}) < 1 );
    
    X = cat(1,filtered.get_embryoID([1:12]).corrected_area_norm);
    X( isnan(X) ) = 0;
    
    X = standardize_matrix(X, 2);
    
    Niter = 100;
    labels_all = nan( Niter, size(X,1) );
    labels_rand = nan( Niter, size(X,1) );
    
    for i = 1:Niter
        
        [~,U] = fcm(X,k,o);
        [~,labels_all(i,:)] = max(U);
        labels_rand(i,:) = randi(k,size(X,1),1);
        
        if mod(i,10) == 0, display('.'); end
    end
    
    RI = zeros(Niter);
    RI_random = zeros(Niter);
    
    for i = 1:Niter
        for j = 1:Niter
            RI(i,j) = rand_index( labels_all(i,:), labels_all(j,:) );
            RI_random(i,j) = rand_index( labels_rand(i,:),labels_rand(j,:) );
        end
    end
    
    display(['Done with k = ' num2str(k) ' U clusters']);
    avgRI(k-1) = mean(RI(:));
    stdRI(k-1) = std(RI(:));
    
    [s,h] = silhouette(X,labels_all(1,:));
    
    for i = 1:k
        meanS(i) = mean(s(labels_all(1,:) == i));
    end
    
    sil{k-1} = meanS;
    avgRI_random(k-1) = mean(RI_random(:));
    stdRI_random(k-1) = std(RI_random(:));
    
end

errorbar(2:10,avgRI,stdRI),xlabel('# of clusters'),ylabel('Rand index')
hold on,errorbar(2:10,avgRI_random,stdRI_random,'r-')

%%

num_clusters = 3;

fits = fits.fcm_cluster(num_clusters,'corrected_area_norm',1);

%%

fits_wt = fits.get_embryoID( 1:5 );
fits_twist = fits.get_embryoID( 6:10 );
% fits_cta = fits.get_embryoID( 8:10 );

clear cluster*

for i = 1:num_clusters
    
    eval(['cluster' num2str(i) ' = fits([fits.cluster_label] == ' num2str(i) ');']);
    
    eval(['cluster' num2str(i) '_wt = fits_wt([fits_wt.cluster_label] == ' num2str(i) ');']);
    eval(['cluster' num2str(i) '_cta = fits_cta([fits_cta.cluster_label] == ' num2str(i) ');']);
    eval(['cluster' num2str(i) '_twist = fits_twist([fits_twist.cluster_label] == ' num2str(i) ');']);
    
    eval(['cluster' num2str(i) '_twist.plot_heatmap']);

end

entries = {'Ratcheted (stereotyped)', ...
    'Ratcheted (early)', ...
    'Ratcheted (delayed)',...
    'Un-ratcheted', ...
    'Stretched'};
colors = {'b','c','g','r','m','k'};

%%

figure

% fits_cta = fits.get_embryoID( 8 );
% [N_const,bins] = hist(revorder([fits_cta( c8([fits_cta.cellID]) == 1 ).cluster_label]), ...
%     1:num_clusters);
% [N_exp,bins] = hist(revorder([fits_cta( c8([fits_cta.cellID]) == 2 ).cluster_label]), ...
%     1:num_clusters);

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

%% summary of clusters

figure
for i = 1:num_clusters
    
    eval(['this_cluster = cluster' num2str(i) '_wt.sort(''cluster_weight'');']);
    cluster_area = cat(1,this_cluster.corrected_area_norm);
    
    subplot(2,num_clusters,i);
    [X,Y] = meshgrid( fits(1).corrected_time,1:numel(this_cluster) );
    pcolor( X,Y, cluster_area );
    shading flat, caxis([-7 7]),colorbar;
        title(['Cluster ' num2str(i) ]);
    xlabel('Pulse time (sec)')
    
    subplot(2,num_clusters,i+num_clusters);
    weights = cat(1, this_cluster.cluster_weight);
    weights = max(weights,[],2);
    shadedErrorBar( fits(1).corrected_time, ...
        nanwmean(cluster_area,weights), nanstd(cluster_area) , colors{i});
    xlabel('Pulse time (sec)')
    ylim( [-6 6] );
    set(gca,'XTick',[-40 0 40]);
    
end

% figure
% % 2D histogram heatmap view
% for i = 1:num_clusters
%     subplot(1,num_clusters,i);
%     eval(['A = cat(1,cluster' num2str(i) '_wt.corrected_area_norm);']);
%     bins = -5:.1:5;
%     N = hist(A,bins);
%     imagesc(fits(1).corrected_time,bins,bsxfun(@rdivide,N,sum(N)));
%     axis square xy;
%     colormap hot;
%     colorbar;
%     xlabel('Pulse time (sec)')
% end

%% Breakdown behavior by embryoID

clear N
for i = 1:num_clusters + 1
    N(i,:) = histc( [fits( [fits.cluster_label] == i).embryoID], [0 5 10 13]);
end

N(4,:) = [];

bar(bsxfun(@rdivide, N, sum(N))' ,'stacked' );
xlim([0 4])
% set(gca,'XTick',[3 12],'XTickLabel',{'WT','twist',''});
% xlabel('EmbryoID')
legend(behaviors{:},'N/A');
