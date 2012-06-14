function nonnans = count_nonans(x)
%COUNT_NONANS Returns the number of non-NaN elements of X.
%
% SYNOPSIS: N = count_nonans(x);
%
% xies@mit.edu June 2012.

x = x(:);
nonnans = numel(x(~isnan(x)));

end
