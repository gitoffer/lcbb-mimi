function [kde_est,kde_bins,tbins,Ninslice,Nzeros,hout] = kde_gauss_temporal_binning(embryo_stack,kde_bins,dt,h)
%KDE_GAUSS_TEMPORAL_BINNING cta-specific wrapper for KSDENSITY or KDE
%
% USAGE:
% [est,est_bins,tbins,Ninslice,Nzeros,h] = kde_gauss_temporal_binning(data,kde_params,temp_params)
%
% INPUT: embryo_stack,
%        kde_bins - If vector: A vector of the KDE evaluation bins
%                   If number of bins is not power of 2, will round up.
%                   If number: the number of KDE bins, from min to max.
%                   Will round to next power of 2.
%        dt - A 1xNembryo vector of time bins for temporal slicing (sec)
%        h - kernel size (Default, uses diffusion estimator from KDE.m)
%
% OUTPUT: KDE_EST - estimate
%         KDE_BINS - evaluation points
%         tbins - left edges of temporal slices
%         Ninbins - number of data points in
%         Nzeros - number of zero crossing for derivative
%         h - kernel size used
%
% SEE ALSO: KSDENSITY, CTA_KDE_AREA, KDE
%
% xies@mit.edu

data = cat(2,embryo_stack.area);

% -- Generate KDE bins --
if isscalar(kde_bins)
    % round to next power of 2
    kde_bins = 2^nextpow2(kde_bins);
    kde_bins = linspace(nanmin(data(:)),nanmax(data(:)),kde_bins);
else
    if rem(log2(numel(kde_bins)),1) ~= 0
        kde_bins = linspace(min(kde_bins),max(kde_bins),2^nextpow2(numel(kde_bins)));
    end
end

% -- KDE ---
kde_est = zeros(numel(tbin_edges) - 1, numel(kde_bins));
Nzeros = zeros( 1, numel(tbin_edges) - 1);
Ninslice = zeros( 1, numel(tbin_edges) - 1);
for i = 1:numel( tbin_edges ) - 1
    
    data_within_slice = nonans( ...
        data( sliceID == i ) );
    
    % RUN KSDENSITY on non-empty sets
    if ~isempty(data_within_slice)
        if nargin == 4
            kde_est(i,:) = ksdensity(data_within_slice, kde_bins, ...
                'Width', h);
            hout = h;
        else
            [h,kde_est(i,:),kde_bins] = kde(data_within_slice, ...
                numel(kde_bins), min(kde_bins), max(kde_bins) );
            if nargout == 6
                hout(i) = h;
            end
        end
        Ninslice(i) = numel(sliceID(sliceID == i));
        ind = crossing( ...
            gaussian_derivative(h,data_within_slice,kde_bins) );
        Nzeros(i) = numel(ind);
    end
    
end

tbins = [min_time tbin_edges( 2 : end - 1 )];

end