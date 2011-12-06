function [Cvv,R] = spatial_correlation_function(V,centroids,dR,Rmax,opt)
%SPATIAL_CORRELATION_FUNCTION Calculates the mean spatial correlation in a
%vector field as a function of distance separation R between vectors.
%
% SYNOPSIS: [Cvv,R] =
% spatial_correlation_function(V,centroids,dR,local,mean_subt)
%
% INPUT: V - vector field
%        centroids - coordinates of the vectors (must be the same size as
%        V)
%        dR - annulus size (to bin R)
%        Rmax - maximum distance to look at (default is max distance)
%        opt - options struct
%           local - 'on'/'off' for local normalization (default is 'off')
%           mean_subt - 'on'/'off' for subtracting the mean vector from the
%           vector field (default is 'off')
% OUTPUT: Cvv - correlation function
%         R - binned distance
%
% xies@mit 11/2011.

% Parse input options
if ~exist('opt','var')
    local = 'off'; mean_subt = 'off';
else
    if ~isfield(opt,'local'), local = 'off'; else local = opt.local; end
    if ~isfield(opt,'mean_subt'), mean_subt = 'off'; else mean_subt = opt.mean_subt; end
end

% Generate distances and binning edges
N = size(V,1);
distances = pdist(centroids);
if ~exist('Rmax','var'), Rmax = max(distances); end
R = 0:dR:Rmax;
edges = R;
edges = [-Inf edges];
nbins = numel(edges);

% Bin the distances
% [counts,which_bins] = histc(distances(:),edges);
%Makes it so that 0 distance vectors are separately binned
[counts,which_bins] = histc(-distances(:),-edges(end:-1:1));
counts = counts';
Cvv = zeros(1,nbins);
which_bins = squareform(which_bins);
which_bins(logical(eye(N))) = 1;

% pdist returns only one side of a symmetric matrix
counts = counts*2;

% Get rid of inf values, also take the mean if mean_subtract is on
V(isinf(V)) = NaN;
if strcmpi(mean_subt,'on')
    means = nanmean(V,1);
    V = V - means(ones(1,N),:);
end

% Take projections of vector at R with vector at 0
if strcmpi(local,'off')
    projections = pdist(V,@project_vectors);
    norms = sqrt(sum(V.^2,2));
else
    projections = pdist(V,@project_vectors_norm);
end
projections = squareform(projections);

% Bin the projections according to distance matrix
for i = 1:nbins
    members = projections(which_bins == i);
    members(isinf(members)) = NaN;
    Cvv(i) = nansum(members);
end

% Divide by count
if strcmpi(local,'off')
    Cvv = (Cvv./counts)./nanmean(norms.^2);
else
    Cvv = Cvv./counts;
end

% Flip the vector
Cvv = Cvv(end:-1:1);

% Get rid of -inf-0 bin
Cvv(1) = [];
% Artificially make 0-distance bin 1
Cvv(1) = 1;

end