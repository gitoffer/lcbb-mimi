function MI = mutual_info(X,Y,nX,nY)

if nargin < 3, nX = 10; nY = 10; end

binsX = linspace(nanmin(X),nanmax(X),nX);
binsY = linspace(nanmin(Y),nanmax(Y),nY);

pX = histc(X,binsX);
pX = pX./nansum(pX);
pY = histc(Y,binsY);
pY = pY./nansum(pY);

pXY = hist2(X,Y,binsX,binsY);
pXY = pXY./nansum(pXY(:));

loggand = bsxfun(@rdivide,pXY,pX);
loggand = bsxfun(@rdivide,loggand',pY)';

MI = nansum(nansum(pXY.*log(loggand)));

% summand = nansum(bsxfun(@rdivide,log(loggand)',pY),2)';
% summand = nansum(bsxfun(@rdivide,summand,pX),1);

% MI = summand;

plotyy(binsX,pX,binsY,pY);

end