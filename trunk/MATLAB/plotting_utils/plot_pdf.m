function [counts,bins,h] = plot_pdf(observations,nbins,varargin)
%PLOT_PDF
% GIven a vector OBSERVATIONS of dimensions 1xD, where there are D
% observations of a random variable, plot the probability density function
% of the variable.
%
% SYNOPSIS: [counts,h] = plot_pdf(x,nbins,patch_options)
%           [counts,h] = plot_pdf(x,patch_options)
% INPUT: x - observed variable
%        nbins - number of bins (default = 30)
%        patch_options - e.g. 'facecolor','red'
% OUTPUT: counts
%        h - figure handle
% 
% See also: PLOT_CDF
%
% xies@mit.edu March 2012.

switch nargin
    case 0
        error('Need at least 1 input!');
    case 1
        nbins = 30;
        patch_opt = {};
end

% check if second opt is number or string
if ischar(nbins)
    patch_opt = {nbins varargin{:}};
    nbins = 30;
else
    patch_opt = varargin;
end

observations = ensure_column(observations);

[counts,bins] = hist(observations,nbins);
prob_mass = sum(counts);
counts = bsxfun(@rdivide,counts,prob_mass);
bar(bins,counts,patch_opt{:});

% h = findobj(gca,'Type','patch');
% if nargin > 2
%     set(h,varargin{:});
% end

% for i = 1:num_var
%     [counts] = hist(observations(:,i),edges);
%     counts = counts/nansum(counts);
%     hold on
%     bar(edges,counts);
%     
%     h = findobj(gca,'Type','patch');
%     
%     if nargin > 2
%         set(h,opts{i,:});
%     end
% end
% hold off

end
