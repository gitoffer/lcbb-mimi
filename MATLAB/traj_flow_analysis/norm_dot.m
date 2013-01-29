function dist = norm_dot(Xi,Xj)
%NORM_DOT Used as a 'distance metric' for calculating SCFs.
% To be used by pdist, and not by itself.
%
% xies@mit. Nov 2010.

N = size(Xj,1);

dist = sum(Xi(ones(1,N),:).*Xj,2)/dot(Xi,Xi);
end
