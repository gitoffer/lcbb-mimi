function [h,cdf,bins] = plot_cdf(observations,bins,varargin)
%PLOT_PDF
% Given a vector OBSERVATIONS of dimensions 1xD, where there are D
% observations of a random variable, plot the cumulative probability
% functionof the variable.
%
% SYNOPSIS: h = plot_cdf(x,bins,line_options)
%           [h,cdf,bins] = plot_cdf(x,bins,line_options)
%           plot_cdf(x,'r-');
% INPUT: x - observed variable
%        nbins - bins (default, linspace 30)
%        line_options - e.g. 'r-'
% OUTPUT: h - figure handle
%         cdf
%         bins
% 
% See also: PLOT_PDF
%
% xies@mit.edu March 2012.

switch nargin
    case 0
        error('Need at least 1 input!');
    case 1
        bins = [];
end

% check that second argin is not a linestyle
if ischar(bins)
    linestyle = {bins};
    bins = [];
else
    linestyle = varargin;
end

if isempty(bins)
    bins = linspace(nanmin(observations(:)),nanmax(observations(:)),30);
end

observations = ensure_row(observations);
bins = ensure_row(bins);

counts = histc(observations,bins);
cdf = cumsum(counts);
normalization_factors = sum(counts(:));
cdf = bsxfun(@rdivide,cdf,normalization_factors);

h = plot(bins,cdf,linestyle{:});


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
