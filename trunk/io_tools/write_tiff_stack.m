function write_tiff_stack(imstack,filename)
%WRITE_TIF_STACK Write a 3D image file as a TIF stack.
%
% SYNOPSIS: write_stuff_stack(imstack,filename)
%  nb: filename must end in .tif
%
% xies@mit.edu

[~, ~, ext] = fileparts(filename);

if ~strcmpi(ext,'.tif'), error('Please provide a .TIF file name.'); end

[X,Y,N,M,L] = size(imstack);
imstack = reshape(imstack,X,Y,N*M*L);
% imstack = gray2ind(imstack,2^8);

for i = 1:N*M*L
    if i == 1
        imwrite(uint8(imstack(:,:,i)),filename,'tif', ...
            'compression','none','writemode','overwrite');
    else
        imwrite(uint8(imstack(:,:,i)),filename,'tif', ...
            'compression','none','writemode','append');
    end
end

end