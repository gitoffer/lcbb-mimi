function h_crit = get_hcrit(data,kde_bins,k_modes,h_scan,deriv_fun)
%GET_HCRIT Find h_critical, the smallest kernel size at which a given
% estimating kernel-derivative (default = Guassian derivative) has at most
% k-modes (default = 1).
%
% USAGE: h_crit = get_hcrit(data, kde_bins, k_modes, h_scan)
%        h_crit = get_hcrit(data, kde_bins, k_modes, h_scan, deriv_fun)
%
% INPUT: data - data to be estimated
%        kde_bins - evaluation bins for KDE
%        k_modes - (default = 1) the modality we want to test for
%        h_scan - a vector of values of h to scan
%        deriv_fun - (default = Gaussian derivative). function handle to
%                    kernel derivative.
%
% Silverman, Bernard W. "Using kernel density estimates to investigate
% multimodality." Journal of the Royal Statistical Society. Series B
% (Methodological) (1981): 97-99.
%
% xies@mit.edu

Nscan = numel(h_scan);
size(data);

for i = 1:Nscan
    
    h = h_scan(i);
    
    ind = corssing( gaussian_derivative(h,data_within_slice,kde_bins) );
    Nmodes = numel(ind);
    
end

keyboard