function [kde_est,kde_bins,Nzeros,hout] = kde_gauss(embryo_stack,kde_bins,sliceID,h,dataname)
%KDE_GAUSS cta-specific wrapper for KSDENSITY or KDE, for use with
% TEMPORAL_SLICE to produce a series of KDEs
%
% USAGE:
% [est,est_bins,tbins,Ninslice,Nzeros,h] = kde_gauss
%
% INPUT: embryo_stack,
%        kde_bins - If vector: A vector of the KDE evaluation bins
%                   If number of bins is not power of 2, will round up.
%                   If number: the number of KDE bins, from min to max.
%                   Will round to next power of 2.
%        sliceID - Output of TEMPORAL_SLICING.m
%        h - kernel size (If not defined, uses diffusion estimator from KDE.m)
%        dataname - defualt = 'area'
%
% OUTPUT: KDE_EST - estimate
%         KDE_BINS - evaluation points
%         Nzeros - number of zero crossing for derivative
%         h - kernel size used
%
% SEE ALSO: KSDENSITY, CTA_KDE_AREA, KDE, TEMPORALLY_SLICE
%
% xies@mit.edu

if nargin < 5, dataname = 'area'; end
data = cat(2,embryo_stack.(dataname) );
% data = embryo_stack;

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
ntbins = numel(unique(sliceID)) - 1;
kde_est = zeros(ntbins, numel(kde_bins));
Nzeros = zeros( 1, ntbins);
for i = 1:ntbins
    
    data_within_slice = nonans( data( sliceID == i ) );
    
    % RUN KSDENSITY on non-empty sets, if h is given
    if ~isempty(data_within_slice)
        
        if nargin == 4
            kde_est(i,:) = ksdensity(data_within_slice, kde_bins, ...
                'Width', h);
            hout = h;
        else
            % OR run KDE if h not given
            [h,kde_est(i,:),kde_bins] = kde(data_within_slice, ...
                numel(kde_bins), min(kde_bins), max(kde_bins) );
            if nargout == 4
                hout(i) = h;
            end
        end
        Nzeros(i) = count_modes_gaussian(h,data_within_slice,kde_bins);
        
    end
    
end

end