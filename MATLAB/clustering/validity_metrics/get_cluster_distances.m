function Dc = get_cluster_distances(D,labels)
% 

% Set Upper triangular of D to NaN (no double counting)
D(logical(triu(ones(size(D))))) = NaN;
D(logical(eye(size(D)))) = NaN;

num_clusters = max(labels);
Dc = zeros(num_clusters);


for i = 1:num_clusters
    for j = 1:num_clusters
        Dc(i,j) = nanmean(nanmean(D(labels == i, labels==j)));
    end
end