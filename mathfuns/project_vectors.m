function dist = project_vectors(xi,Xj)
%PROJECT_VECTORS Projects vectors Xj onto xi. Rows of Xj represent
%different vectors.

N = size(Xj,1);
dist = sum(xi(ones(1,N),:).*Xj,2);
end