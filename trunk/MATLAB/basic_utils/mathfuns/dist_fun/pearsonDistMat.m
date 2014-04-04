function Dp = pearsonDistMat( X , Y)
%pearsonDistMat
% Hopefully faster than pdist

switch nargin
    case 1
        Y = X;
end

[N,p] = size(X); M = size(Y,1);

% Replace NaN with 0 - will not change cov or var
X( isnan(X) ) = 0; Y( isnan(Y) ) = 0;

% mean subtract
dev_x = bsxfun( @minus, X, nanmean(X,2) );
dev_y = bsxfun( @minus, Y, nanmean(Y,2) );

% take std
stdx = sqrt( var(dev_x,[],2) );
stdy = sqrt( var(dev_y,[],2) );

% calculate covariance (bessel correction) and divide by sqrt(var)
Dp = dev_x * dev_y' / (p-1) ...  % norm cov
    ./ (stdx * stdy');
%     ./ stdx(:, ones(1,N) ) ./ stdy(:, ones(1,M) );

end
