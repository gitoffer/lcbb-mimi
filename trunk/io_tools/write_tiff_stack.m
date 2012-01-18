function write_tiff_stack(imstack,filename)
%WRITE_TIF_STACK Write a 3D image file as a TIF stack.
%
% SYNOPSIS: write_stuff_stack(imstack,filename)
%
% xies@mit.edu

[X,Y,N,M,L] = size(imstack);
imstack = reshape(imstack,X,Y,N*M*L);

for i = 1:N*M*L
	imwrite(uint8(imstack(:,:,i)),filename,'tif','compression','none','writemode','append');
end
