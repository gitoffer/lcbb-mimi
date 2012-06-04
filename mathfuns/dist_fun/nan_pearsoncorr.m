function corrcoef = nan_pearsoncorr(a,b)
%NANCORRCOEF Calculates the Pearson correlation coefficient for vectors A
%and B that has NaNs. Only supported for 1D vectors and 2 inputs.
%
% USE: corrcoef = nan_personcorr(a,b);
%
% xies@mit.edu March 2012.

N = size(b,1);

corrcoef = zeros(1,N);
for i = 1:N
    covMat = nancov(a,b(i,:));
    variances = diag(covMat);
    covMat = covMat./sqrt(variances*variances');
    corrcoef(i) = covMat(1,2);
end

end