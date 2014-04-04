function corrcoef = nan_pearsoncorr(a,b,lag)
%NANCORRCOEF Calculates the Pearson correlation coefficient for vectors A
%and B that has NaNs. Only supported for 1D vectors and 2 inputs.
%
% USE: corrcoef = nan_personcorr(a,b);
%
% xies@mit.edu March 2012.

if nargin < 3, lag = 0; end

[N,T] = size(b);
a = a(:,max(1,1-lag):min(T,T-lag));
b = b(:,max(1,1+lag):min(T,T+lag));

corrcoef = zeros(1,N);
for i = 1:N
    covMat = nancov(a,b(i,:));
    variances = diag(covMat);
    covMat = covMat./sqrt(variances*variances');
    corrcoef(i) = covMat(1,2);
end

% corrcoef = 2*(1-corrcoef);

end
