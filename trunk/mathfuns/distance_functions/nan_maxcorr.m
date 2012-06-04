function correlations = nan_maxcorr(x,Y,wt)
%NANXCORR Uses NANCOV to calculate the cross correlation between two
%signals when NaN is present.
%
% SYNOPSIS: correlations = nanxcorr(A,B,wt)
%               By default correlate across the first dimension
%           correlations = nanxcorr(A,B,wt,dim)
%               Denote which dimension you want to correlate
%
% Modiefied from acmartin. xies@mit.edu Jan 2012.

% if ~exist('dim','var'), dim = 1; end
% if any(size(B) ~= size(A)), error('Input matrices must be the same size.'); end

[N,T] = size(Y);
correlations = nan(N);

for i = 1:N
    corr = zeros(ones(1,2*wt+1));
    for t = -wt:wt
        signal = cat(1,x(max(1,1+t):min(T,T+t)), ...
            Y(i,max(1,1-t):min(T,T-t)));
        cov_mat = nancov(signal);
        variances = diag(cov_mat);
        corr(t) = cov_mat./sqrt(variances*variances');
    end
    correlations = nanmax(corr(1,2));
end

end
