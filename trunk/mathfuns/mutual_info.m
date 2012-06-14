function MI = mutual_info(pXY)
%MUTUAL_INFO Calculates the mutual information for two variables X,Y
% given their joint distributions, p(X,Y). The first dimension is assumed
% to be X. NaN values not tolerated. Discrete variables.
%
% SYNOPSISI: MI = mutual_infor(joint_distribution);
%
% xies@mit.eud June 2012.

if size(pXY,1) ~= size(pXY,2), error('The two random variables must have the same size'); end

% Get the marginal probability distributions
pX = sum(pXY,1); pY = sum(pXY,2);

pX(pX == 0) = NaN; pY(pY == 0) = NaN;

loggand = bsxfun(@rdivide, pXY, pX);
loggand = bsxfun(@rdivide, loggand, pY);
loggand(loggand == 0) = NaN;

MI = nansum(nansum(pXY.*log(loggand)));

%Unit test
if MI < 0,keyboard,end

end