function dist = norm_dot(Xi,Xj)
%NORM_DOT Takes the dot product of an array of vectors with a single vector.
% To be used by pdist/pdist2, not by itself.
%
% xies@mit.

N = size(Xj,1);

dist = sum(Xi(ones(1,N),:).*Xj,2)/dot(Xi,Xi);
end
