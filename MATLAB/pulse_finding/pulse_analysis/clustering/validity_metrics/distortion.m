function dk = distortion(data,labels)
%DISTORTION Calculates the jump-distortion value for a given clustering
% scheme.
%
% Definition:
%    the average normalized k-means distance between every datum and its
%    centroid to the -Y power
%   d_k = \frac{1}{p} d(X_i,c_i)
%
% USAGE: dk = jump_transform( data, labels, power)
%
% INPUTS: data - NxP (N - number of data, p - dimension of data)
%         labels - cluster labels (N-dim vector)
% OUTPUT: dk - the distortion statistic
%
% References: Sugar, C. A., & James, G. M. (2003). Finding the number of 
% clusters in a dataset: An information-theoretic approach. Journal of the 
% American Statistical Association, 98(463), 750-763.
% 
% xies@mit.edu June 2013

[N,p] = size(data);

k = numel(unique(labels));
raw_dist = zeros(1,N);
for i = 1:k
    raw_dist(labels==i) = nan_eucdist( ...
        nanmean( data(labels==i,:)),data(labels==i,:) ...
        );
end

dk = mean(raw_dist(:));

end