%CLUSTER_DATA_SCRIPT Script to interface with MATLAB Bioinformatics Toolbox
% CLUSTERGRAM function.

data2cluster = corrected_area_norm(:,:);
[data2cluster,dataIDs] = delete_nan_rows(data2cluster,1,'all');
standardized_myosin = standardize_matrix(corrected_myosin,2);
standardized_area_norm = standardize_matrix(data2cluster,2);
standardized_area_rate = standardize_matrix(corrected_area_rate,2);

%% Clustering settings
clustering.dist_fun = @nan_eucdist;
% clustering(1).dist_fun = @nan_stsd;
% clustering.dist_fun = @nan_pearsoncorr;
distances = pdist(data2cluster,clustering(1).dist_fun);

%%

Z = linkage(distances,'complete');
% figure,h = dendrogram(Z,0,'Orientation','left');

%%

for i = 1:20
    clsutering(i).dist_fun = @nan_stsd;
    clustering(i).distances = distances;
%     clustering(i).labels = kmeans
    clustering(i).labels = cluster(Z,'maxclust',i+1);
    metrics(i) = validate_cluster(clustering(i),'connectivity');
end

%% Uses the cluster visualization GUI

visualize_cluster(data2cluster(cluster_order,:),cluster_labels,[-8 8],standardized_area_norm(cluster_order,:))
% visualize_cluster(corrected_area_norm(kmeansID,:),kmeans_labels,[-8 8],standardized_myosin)

%% Use Multi-dimensional scaling to visualize clsuters

[Y,stress,disparities] = mdscale(squareform(distances),3,'criterion','sstress');
save('~/Desktop/Aligned embryos/WT/mdspoints','Y','stress','disparities');
