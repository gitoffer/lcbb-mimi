function dist = nan_eucdist(Xi,Xj)

N = size(Xj,1);
dist = sqrt(nansum((Xj - Xi(ones(1,N),:)).^2,2));

end