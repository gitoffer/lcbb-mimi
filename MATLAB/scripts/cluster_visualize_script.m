%CLUSTER_DATA_SCRIPT Script to interface with MATLAB Bioinformatics Toolbox
% Collection of scripts used to visualize clusters
%% Select data to cluster or plot

data2cluster = corrected_area_norm(:,:);
[data2cluster,dataIDs] = delete_nan_rows(data2cluster,1,'all');
standardized_myosin = standardize_matrix(corrected_myosin,2);
standardized_area_norm = standardize_matrix(data2cluster,2);
standardized_area_rate = standardize_matrix(corrected_area_rate,2);

%% Generate distance matrix
D = pdist(standardized_area_norm,@nan_pearsoncorr);
D = squareform(D);
D_p2 = pdist(standardized_area_norm,@nan_eucdist);
D_p2 = squareform(D_p2);

%% Uses the cluster visualization GUI

visualize_cluster(standardized_area_norm(cluster_order,:),cluster_labels,[-3 3],standardized_myosin(cluster_order,:))
% visualize_cluster(corrected_area_norm(kmeansID,:),kmeans_labels,[-8 8],standardized_myosin)

%% Use Multi-dimensional scaling to visualize clsuters

[Y,stress,disparities] = mdscale(squareform(distances),3,'criterion','sstress');
save('~/Desktop/Aligned embryos/WT/mdspoints','Y','stress','disparities');

%% Subplots of pulseOI (restricted pulse-set)

% figure,
data2cluster = standardized_area_norm;

num_clusters = max(cluster_labels);
num_peaks = numel(pulseOI);
foo = num_clusters:-1:1;
colors = varycolor(num_clusters);

subplot(num_clusters,2,1:2:2*num_clusters-1);
[X,Y] = meshgrid(corrected_time,1:num_peaks);

pcolor(X,Y,data2cluster(cluster_order(cluster_order < wt_cutoff),:))
shading flat,caxis([-3 3]);
xlabel('Aligned time (sec)'); ylabel('PulseID');

for which = 1:num_clusters
    subplot(num_clusters,2,2*which);
    shadedErrorBar(corrected_time, ...
        nanmean(data2cluster([pulseOI.cluster_label] == foo(which),:)), ...
        nanstd(data2cluster([pulseOI.cluster_label] == foo(which),:)),{'color',colors(which,:)});
    title(['Cluster ' num2str(which)]);
    set(gca,'Xlim',[-20 70],'Ylim',[-3 3]);
end
xlabel('Aligned time (sec)'); ylabel('Z-score');
suptitle(['Pearson clustering with ' num2str(num_clusters) ' clusters']);
