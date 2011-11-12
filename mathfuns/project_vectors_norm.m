function dist = project_vectors_norm(xi,Xj)
%PROJECT_VECTORS_NORM Projects vectors Xj onto xi. Rows of Xj represent
%different vectors.

N = size(Xj,1);
dist = sum(xi(ones(1,N),:).*Xj,2)./norm(xi).^2;
end