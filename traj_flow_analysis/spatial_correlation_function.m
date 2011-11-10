function [Cvv,R] = spatial_correlation_function(X,centroids,nbins)

N = size(X,1);
distances = pdist(centroids);
% min_d = min(distances);
max_d = max(distances);
R = linspace(0,max_d,nbins);

[counts,which_bins] = histc(distances,R);
Cvv = zeros(1,nbins);
which_bins = squareform(which_bins);

projections = pdist(V,@project_vectors);
projections = squareform(projections);
projections(logical(eye(N))) = 1;

norms = sqrt(sum(V.^2,2));
norms(isinf(norms)) = NaN;


for i = 1:nbins
    members = projections(which_bins == i);
    members(isinf(members)) = NaN;
    Cvv(i) = nansum(members);
end
Cvv = Cvv./counts;

%Add in the 0 distance terms
% Cvv = [1 Cvv];
% R = [0 R];
end