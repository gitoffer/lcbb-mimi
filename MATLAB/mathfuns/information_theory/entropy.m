function S = entropy(X)

if ~isvector(X),error('Input should be a vector.');end

S = nansum(X.*log(X));