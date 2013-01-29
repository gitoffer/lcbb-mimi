function [X,Y] = list2grid(V,n,m)

[N,d] = size(V);
if d ~= 2, error('Can only handle 2D data.'); end
if N/m ~= n, error('Invalid dimensions.'); end

X = V(:,1);
Y = V(:,2);
X = reshape(X,n,m);
Y = reshape(Y,n,m);