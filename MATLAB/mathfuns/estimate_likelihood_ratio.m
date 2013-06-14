function ratio = estimate_likelihood_ratio(measurement,background,bins)
%ESTIMATE_LIKELIHOOD_RATIO Uses historgram method to estimate the relative
% likelihood (ratio) of data in MEASUREMENT versus BACKGROUND. Will add a
% pseudocount for stability. (Will flatten data.)
%
% SYNOPSIS: ratio = estimate_likelihood_ratio(measurement,bg,bins);
% xies@mit.edu May 2013

if nargin < 3 || isempty(bins)
    bins = linspace(-15,15,201);
end

% flatten inputs
measurement = measurement(:); background = background(:);

% get background histogram
bg = hist(background,bins);

% get measurement histogram
ms = hist(measurement,bins);

% add pseudocount
% bg = bg + 1; ms = ms + 1;

% normalize to probability
bg = bg/sum(bg); ms = ms / sum(ms);

% get likelihood-ratio
ratio = bg./ms;

% ratio( ms == 0 ) = NaN;
% ratio( bg == 0 ) = Inf;

end