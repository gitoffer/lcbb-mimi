function [kde_est,kde_bins,tbins,Ninslice,Nzeros] = kde_gauss_temporal_binning(embryo_stack,kde_bins,dt,h)
%KDE_GAUSS_TEMPORAL_BINNING cta-specific wrapper for KSDENSITY designed to
% generate a series of KDE based on binning data temporally
%
% USAGE:
% [est,est_bins] = kde_gauss_temporal_binning(data,kde_params,temp_params)
%
% INPUT: embryo_stack,
%        kde_bins - If vector: A vector of the KDE evaluation bins
%                   If number: the number of KDE bins
%        dt - A 1xNembryo vector of time bins for temporal slicing (sec)
%        h - kernel size
%
% OUTPUT: KDE_EST - estimate
%         KDE_BINS - evaluation points
%         tbins - left edges of temporal slices
%         Ninbins - number of data points in
%         Nzeros - number of zero crossing for derivative
%
% SEE ALSO: KSDENSITY, CTA_KDE_AREA
%
% xies@mit.edu

data = cat(2,embryo_stack.area);

% -- Generate KDE bins --
if isscalar(kde_bins)
    kde_bins = linspace(nanmin(data(:)),nanmax(data(:)),kde_bins);
end

% -- Generate temporal slicing --
min_time = nanmin([embryo_stack.dev_time]);
max_time = nanmax([embryo_stack.dev_time]);
tbin_edges = [-Inf min_time + dt: dt :max_time - dt Inf];
[~,which_slice] = histc(cat(1,embryo_stack.dev_time),tbin_edges);
sliceID = zeros(size(data));
% Expand binID from embryo to each cell
padding = [0 cumsum([embryo_stack.num_cell])];
for i = 1:numel( embryo_stack )
    sliceID(: , padding(i) + 1 : embryo_stack(i).num_cell + padding(i)) = ...
        which_slice( ones(1,embryo_stack(i).num_cell)*i , :)';
end

% -- KDE ---
kde_est = zeros(numel(tbin_edges) - 1, numel(kde_bins));
Ninslice = zeros( 1, numel(tbin_edges) - 1);
for i = 1:numel( tbin_edges ) - 1
    
    data_within_slice = nonans( ...
        data( sliceID == i ) );
    
    % RUN KSDENSITY on non-empty sets
    if ~isempty(data_within_slice)
%         kde_est(i,:) = ksdensity(data_within_slice, kde_bins, ...
%             'Width', h);
        kde_est(i,:) = feval(fun,h,data_within_slice,kde_bins);
        Ninslice(i) = numel(sliceID(sliceID == i));
    
    end
    
end

tbins = [min_time tbin_edges( 2 : end - 1 )];

end