function sil = silhouette_width(cluster)
%SILHOUETTE_WIDTH Calcualtes the average silhouette value for a given DATA
%and CLUSTERING result.
%
% SYNOPSIS: sil = silhouette_width(data,cluster);
%
% xies@mit.edu

D = squareform(cluster.distances);
labels = cluster.labels;
N = size(D,1);

num_clusters = numel(unique(labels));
sil = zeros(1,N);

for i = 1:N
    this_cluster = labels(i);
    a = sum(D(i,labels == this_cluster))/numel(labels(labels == this_cluster));
    b = zeros(1,num_clusters-1); ind = 0;
    for j = setdiff(1:num_clusters,this_cluster)
        ind = ind+1;
        b(ind) = sum(D(i,labels == j))/numel(labels(labels == j));
    end
    sil(i) = (min(b)-a)/max(min(b),a);
end

sil = nanmean(sil);