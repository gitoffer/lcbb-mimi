function X = nonans(x)
%NONANS Returns non-NaN elements of X.
%
% SYNOPSIS: X = nonans(x);
%
% xies@mit.edu June 2012.

X = x(~isnan(x));

end
