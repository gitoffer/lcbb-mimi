function fom = figure_of_merit(data,clustering)

labels = clsutering.labels;
D = squareform(clustering.distances);

num_clusters = numel(unique(labels));

[N,p] = size(data);

for i = 1:p
    this_cluster_average = nanmean(data(labels==i,:));
    distances = pdist2(data
end