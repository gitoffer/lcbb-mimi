function conn = connectivity_index(cluster,L)
%CONNECTIVITY_INDEX Finds the connectivity index
%
% SYNOPSIS: CONN = connectivity_index(cluster)
%
% xies@mit.edu
% UNTESTED

D = squareform(cluster.distances);
labels = cluster.labels;
labels = ensure_row(labels);

N = size(D,1);

if nargin < 2
    L = N/2;
end

[~,ind] = sort(D,1,'ascend');

label_matrix = labels(ones(1,N),:);

diffs = label_matrix;
for i = 1:N %Not optimal?
    diffs(i,:) = labels(ind(:,i)) ~= labels(i);
end
diffs = diffs(:,1:L)';

order = (1:L)';
weights = 1./order(:,ones(1,N));

conn = diffs.*weights;
conn = sum(conn(:));

end