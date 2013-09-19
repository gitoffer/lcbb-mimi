%% Stability analysis of FCM clustering

o = [2 100 1e-5 0];

for k = 3:10
    
    X = cat(1,fits.corrected_area_norm);
    X( isnan(X) ) = 0;
    
    % X = standardize_matrix(X, 2);
    
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
    
    display(['Done with k = ' num2str(k) ' clusters']);
    avgRI(k-2) = mean(RI(:));
    stdRI(k-2) = std(RI(:));

    avgRI_random(k-2) = mean(RI_random(:));
    stdRI_random(k-2) = std(RI_random(:));
    
end

errorbar(3:10,avgRI,stdRI),xlabel('# of clusters'),ylabel('Rand index')
hold on,errorbar(3:10,avgRI_random,stdRI_random,'r-')

%%

fits = fits.fcm_cluster(5,'corrected_area_norm',3);

%%

fits_wt = fits.get_embryoID( 1:5 );
fits_twist = fits.get_embryoID( 6:7 );
fits_cta = fits.get_embryoID( 8:10 );

clear cluster*

for i = 1:5+1
    
    eval(['cluster' num2str(i) ' = fits([fits.cluster_label] == ' num2str(i) ');']);
    
    eval(['cluster' num2str(i) '_wt = fits_wt([fits_wt.cluster_label] == ' num2str(i) ');']);
    eval(['cluster' num2str(i) '_cta = fits_cta([fits_cta.cluster_label] == ' num2str(i) ');']);
    eval(['cluster' num2str(i) '_twist = fits_twist([fits_twist.cluster_label] == ' num2str(i) ');']);
    
    eval(['cluster' num2str(i) '_wt.plot_heatmap']);

end

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};
colors = {'b','c','g','r','m','k'};

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


%% summary of clusters

figure

for i = 1:num_clusters
    
    eval(['this_cluster = cluster' num2str(i) '.sort(''cluster_weight'');']);
    cluster_area = cat(1,this_cluster.corrected_area_norm);
    
    subplot(2,num_clusters,i);
    [X,Y] = meshgrid( fits(1).corrected_time,1:numel(this_cluster) );
    pcolor( X,Y, cluster_area );
    shading flat, caxis([-10 10]),colorbar;
        title(['Cluster ' num2str(i) ]);
    xlabel('Pulse time (sec)')
    
    subplot(2,num_clusters,i+num_clusters);
    weights = cat(1, this_cluster.cluster_weight);
    shadedErrorBar( fits(1).corrected_time, ...
        nanwmean(cluster_area,weights), nanstd(cluster_area) , colors{i});
    xlabel('Pulse time (sec)')
    set(gca,'XTick',[-40 0 40]);
    
end

%% Breakdown behavior by embryoID

clear N
for i = 1:num_clusters
    N(i,:) = hist( [fits( [fits.cluster_label] == i).embryoID] ,1:10);
end

bar(1:10, bsxfun(@rdivide, N, sum(N))' ,'stacked' );
xlim([0 11])
xlabel('EmbryoID')
legend(entries{:});
