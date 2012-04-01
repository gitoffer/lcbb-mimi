function corrcoef = nan_pearsoncorr(a,b)
%NANCORRCOEF Calculates the Pearson correlation coefficient for vectors A
%and B that has NaNs. Only supported for 1D vectors and 2 inputs.
%
% USE: corrcoef = nan_personcorr(a,b);
%
% xies@mit.edu March 2012.

covMat = nancov(a,b);
covMat = covMat./nanstd(a)./nanstd(b);
corrcoef = covMat(1,2);

end