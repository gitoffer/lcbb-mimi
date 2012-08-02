function X = nonans(x,dim)
%NONANS Returns non-NaN elements of X.
%
% SYNOPSIS: X = nonans(x);
%
% xies@mit.edu June 2012.

switch nargin
    case 1
        X = x(~isnan(x));
    case 2
%         N = ndims(x);
%         x = circshift(x,dim);
        X = x(~any(isnan(x)),dim);
end