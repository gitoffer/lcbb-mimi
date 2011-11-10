function dist = norm_dot(Xi,Xj)


N = size(Xj,1);

dist = sum(Xi(ones(1,N),:).*Xj,2)/dot(Xi,Xi);
end