function df = smooth_differentiate(f,method)
%SMOOTH_DIFFERENTIATE Smooth-filter and differentiate a 1D signal.
%
% SYNOPSIS: df = smooth_differentiate(f,method)
% 
% INPUT: f - 1D array of the signal
%				 method - a string
%
% OUTPUT: df - differentiated filter
% xies@mit Jan 8
% NOT FINISHED!

if ~exist('method','var')
    method = 'sgolay';
end

filtered = smooth(f,method);
df = diff(filtered);