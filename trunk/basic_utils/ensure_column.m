function vector = ensure_column(vector)
%ENSURE_ROW Makes a vector a column-vector.
%
% SYNOPSIS: v = ensure_column(v)
% xies@mit.edu

if ~isvector(vector), error('Needs a vector as input!'); end

if isrow(vector), vector = vector'; end