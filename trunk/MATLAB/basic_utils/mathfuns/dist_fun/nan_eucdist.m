function dist = nan_eucdist(Xi,Xj)
%NAN_EUCDIST Performs Euclidean distance on vectors for clustering. Will
%throw out NaNs from the vector and divide by the number of non-NaN
%dimensions. Square root is not performed
%
% xies@mit.edu Aug 2012

N = size(Xj,1);

dim_i = numel(Xi(~isnan(Xi)));

% dim_j = zeros(N,1);

dim_j = sum(~isnan( Xj ), 2);
% for j = 1:N
%     this_Xj = Xj(j,:);
%     dim_j(j) = numel(this_Xj(~isnan(this_Xj)));
% end
num_nan = min(dim_i,dim_j);

dist = sqrt(nansum((Xj - Xi(ones(1,N),:)).^2,2));
% dist = dist./num_nan;

end
