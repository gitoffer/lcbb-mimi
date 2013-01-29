function [Ct,taus] = temporal_correlation_function(V,dT,Tmax,opt)
%TEMPORAL_CORRELATION_FUNCTION Calculates the mean temporal correlation in a
%vector field as a function of distance separation R between vectors.
%
% SYNOPSIS: [Cvv,R] =
% spatial_correlation_function(V,centroids,dR,local,mean_subt)
%
% INPUT: V - vector field in the format: V(t,x,y,:)
%        dT - annulus size (to bin R)
%        Tmax - maximum distance to look at (default is max distance)
%        opt - options struct
%           mean_subt - 'on'/'off' for subtracting the mean vector from the
%           vector field (default is 'off')
% OUTPUT: Ct - temporal correlation
%         taus - binned time lags
%
% xies@mit 11/2011.

flat = @(x) x(:);
% Parse input options
if ~exist('opt','var')
    mean_subt = 'off';
else
    if ~isfield(opt,'mean_subt'), mean_subt = 'off'; else mean_subt = opt.mean_subt; end
end

% Create a distance matrix based on the time lags
T = size(V,1);
taus = 0:dT:Tmax;
edges = [-Inf taus];
nbins = numel(edges);

% Calculate pairwise correlations
dist = pdist((1:T)','cityblock');
dist = squareform(dist);
% Flip bins so that tau = 0 is its own bin
[counts,which_bins] = histc(-dist(:)',-edges(end:-1:1));
% which_bins = squareform(which_bins);
% which_bins(logical(eye(T))) = 2;
which_bins = reshape(which_bins,T,T);

Ct = zeros(1,nbins);

for i = 1:T
    for j = 1:T
        if which_bins(i,j) ~= 0
%             if strcmpi(mean_subt,'on')
%                 V(i,:,:,1) = V(i,:,:,1) - nanmean(flat(V(i,:,:,1)));
%                 V(i,:,:,2) = V(i,:,:,2) - nanmean(flat(V(i,:,:,2)));
%                 V(j,:,:,1) = V(j,:,:,1) - nanmean(flat(V(j,:,:,1)));
%                 V(j,:,:,2) = V(j,:,:,2) - nanmean(flat(V(j,:,:,2)));
%             end
            correlations = dot_vectorfields(V(i,:,:,:),V(j,:,:,:))...
                ./norm_vectorfield(V(i,:,:,:)).^2;
            Ct(which_bins(i,j)) = Ct(which_bins(i,j)) + nanmean(correlations(:));
        end
    end
end
Ct = Ct./counts;
Ct = Ct(end:-1:1);
Ct(1) = [];

end