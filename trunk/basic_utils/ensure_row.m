function vector = ensure_row(vector)
%ENSURE_ROW Makes a vector a row-vector.
%
% SYNOPSIS: v = ensure_row(v)
% xies@mit.edu

if ~isvector(vector), error('Needs a vector as input!'); end

if iscolumn(vector), vector = vector'; end