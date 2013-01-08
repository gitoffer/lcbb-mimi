function DI = dunn_index(cluster)
%DUNN_INDEX Calculates the Dunn index of a dataset according to a
% particular clustering result
% SYNOPSIS: DI = dunn_index(data,cluster)
%
% xies@mit.edu
flat = @(x) x(:);

num_cluster = numel(unique(cluster.labels));
labels = cluster.labels;
D = squareform(cluster.distances);

intra_clust_dist = zeros(1,num_cluster);
diam = zeros(1,num_cluster);

for i = 1:num_cluster
    intra_clust_dist(i) = nanmin(flat(D(labels == i,labels~=i)));
    diam(i) = nanmax(flat(D(labels == i, labels == i)));
end

min_intra_clust_dist = nanmin(intra_clust_dist);

max_diam = nanmax(diam);

DI = min_intra_clust_dist/max_diam;

end