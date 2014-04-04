function S = entropy(X)
%ENTROPY

if ~isvector(X),error('Input should be a vector.');end

S = nansum(X.*log(X));