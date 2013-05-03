function [num_clusters,num_members,cluster_names] = get_cluster_numbers(cluster_labels)
%GET_CLUSTER_NUMBER Calculates the total number of clusters as well as the
%number of members of each cluster given a set of cluster labels
%
% USAGE: [num_clusters,num_members,cluster_names] = 
%            get_cluster_members(cluster_labels);
% 
% xies@mit.edu Jan 2013

num_clusters = numel(unique(cluster_labels));
num_members = zeros(1,num_clusters);
cluster_names = cell(1,num_clusters);
for i = 1:num_clusters
    num_members(i) = numel(cluster_labels(cluster_labels == i));
    cluster_names{i} = ['Cluster ' num2str(i)];
end

end
