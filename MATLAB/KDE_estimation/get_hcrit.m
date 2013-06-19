function [h_crit,Nmodes] = get_hcrit(data,kde_bins,k_modes,h_scan,sliceID)
%GET_HCRIT Find h_critical, the smallest kernel size at which a given
% estimating kernel-derivative has at most k-modes (default = 1). Will do
% temporal slicing if sliceID is given.
%
% USAGE: h_crit = get_hcrit(embryo_stack,kde_bins,sliceID,k_modes,h_scan)
%
% INPUT: data - data to be estimated
%        kde_bins - evaluation bins for KDE
%        k_modes - (default = 1) the modality we want to test for
%        h_scan - a vector of values of h to scan
%        sliceID - (optional) bin data into different slices
% OUTPUT: h_crit - the smallest h at which there are at most k modes.
%
% Silverman, Bernard W. "Using kernel density estimates to investigate
% multimodality." Journal of the Royal Statistical Society. Series B
% (Methodological) (1981): 97-99.
%
% xies@mit.edu

% Parse sliceID or construct a dummy
if nargin > 4
    Nslice = numel(unique(sliceID)) - 1;
else
    Nslice = 1;
    sliceID = ones(size(data));
end

h_crit = zeros(1,Nslice);
Nscan = numel(h_scan);
Nmodes = zeros(Nslice,Nscan);
for t = 1:Nslice
    
    data_within_slice = nonans(data( sliceID == t ));
    for i = 1:Nscan
        h = h_scan(i);
        % Find the number of modes from zero-crossings
        ind = crossing( gaussian_derivative(h,data_within_slice,kde_bins) );
        Nmodes(t,i) = numel(ind);
    end
    
    % Grab smallest h, use fact that Nmodes is monotonically decreasing.
    ind = find(Nmodes(t,:) == 1,1,'first');
    if isempty(ind), ind = numel(h_crit); end
    h_crit(t) = h_scan(ind);
    
end

end