function Xi = interp_mat(X,dim)

N = size(X,1);

Y = 1:size(X,2);
for i = 1:N
    signal = X(i,:);
    Xi(i,:) = interp1(Y(~isnan(signal)),signal(~isnan(signal)),Y);
end
end