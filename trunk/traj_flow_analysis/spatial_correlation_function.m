function [Cvv,R] = spatial_correlation_function(V,centroids,nbins,local,mean_subt)

if ~exist('local','var'), local = 'off'; end
if ~exist('mean_subt','var'), mean_subt = 'off'; end

N = size(V,1);
distances = pdist(centroids);
min_d = min(distances);
max_d = max(distances);
R = linspace(min_d,max_d,nbins-1);
edges = [-inf R];

[counts,which_bins] = histc(distances,edges);
Cvv = zeros(1,nbins);
which_bins = squareform(which_bins);
which_bins(logical(eye(N))) = 1;

counts = counts*2;

V(isinf(V)) = NaN;
if strcmpi(mean_subt,'on')
    means = nanmean(V,1);
    V = V - means(ones(1,N),:);
end

if strcmpi(local,'off')
    projections = pdist(V,@project_vectors);
    norms = sqrt(sum(V.^2,2));
%     norms(isinf(norms)) = NaN;
else
    projections = pdist(V,@project_vectors_norm);
end
projections = squareform(projections);

% projections(logical(eye(N))) = norms.^2;

for i = 1:nbins
    members = projections(which_bins == i);
%     members(isinf(members)) = NaN;
    Cvv(i) = nansum(members);
end

if strcmpi(local,'off')
    Cvv = (Cvv./counts)/nanmean(norms.^2);
else
    Cvv = Cvv./counts;
end

Cvv(1) = 1;
R = [0 R];
%Add in the 0 distance terms
% Cvv = [1 Cvv];
% R = [0 R];

end