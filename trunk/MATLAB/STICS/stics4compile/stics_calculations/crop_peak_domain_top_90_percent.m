
function [f, x,y] = crop_peak_domain_top_90_percent(f, x,y, varargin)
% Purpose: 
% Take a set of samples of a shifted 2-D Gaussian peak f_i = f(y_i,x_i)  
% for i in S and find a reduced  set S' < S, to impove fitting performance.
% Meant to be used with gauss2d_fit.m
% Input:
%   f,x,y -- data matrices or vector of the same size, interpreted as
%   samples f(y,x)
% Output: 
%   A reduced set of f,x,y.   top_90_% returns the top 90% of the function
%   values.
% 
cutoff  = 0.1;
if ~isempty(varargin)
    cutoff = varargin{1};
end
% do nothing
i = find(stretch(f) >= cutoff);
f  = f(i);
x  = x(i);
y  = y(i);
end