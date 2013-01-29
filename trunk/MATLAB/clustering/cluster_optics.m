function labels = cluster_optics(rd,order,threshold)

mask = rd > threshold;
N = numel(rd);

one_indices = [0 find(mask) N];

cluster_counts = diff(one_indices);
num_clusters = numel(cluster_counts);

labels = ones(1,N);
for i = 1:num_clusters
    labels(one_indices(i)+1:one_indices(i+1)) = ...
        i*ones(1,cluster_counts(i));
end
labels = labels(reverse_index(order));

end