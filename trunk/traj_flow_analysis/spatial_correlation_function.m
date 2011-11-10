function [Cvv,R] = spatial_correlation_function(V,centroids,nbins)

distances = pdist(centroids);
min_d = min(distances);
max_d = max(distances);
R = linspace(min_d,max_d,nbins);
[counts,which_bins] = histc(distances,R);
Cvv = zeros(1,nbins);
dot_products = pdist(V,@norm_dot);

for i = 1:nbins
    members = dot_products(which_bins == i);
    members(isinf(members)) = NaN;
    Cvv(i) = nansum(members);
end
Cvv = Cvv./counts;

%Add in the 0 distance terms
Cvv = [1 Cvv];
R = [0 R];
end