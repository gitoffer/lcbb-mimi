function Dn = standardize_matrix(D,dim)
%NORMALIZE_MATRIX Mean-center and normalize a matrix by the standard
% deviation, along the specified direction. (Only 2D matrices supported
% now.)
%
% SYNOPSIS: D_standard = standardize_matrix(D,2);
%
% xies@mit.edu

if dim == 1, D = D'; end

Dn = bsxfun(@minus,D,nanmean(D,2));
Dn = bsxfun(@rdivide,Dn,nanstd(Dn,[],2));

if dim == 1, Dn = Dn'; end