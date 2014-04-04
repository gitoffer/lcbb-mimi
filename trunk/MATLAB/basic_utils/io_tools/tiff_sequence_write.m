function tiff_sequence_write(stack,name_base)
%TIFF_SEQUENCE_WRITE Writes a matrix as a sequence of multiple TIF files.
%
% SYNOPSIS: tiff_sequence_write(stack,name_base)
% 
% Will use '_t', '_z' to append to name_base, according to the size of the
% given image array, i.e. [Y,X,num_frames,num_slices] = size(stack)
% where _t corresponds to num_frames, and _z to num_slices
%
% xies@mit.edu May 2012.

[~,~,num_frames,num_slices] = size(stack);

for i = 1:num_frames
    for j = 1:num_slices
        name = sprintf('%s%s%03d%s%03d%s',name_base,'_t',i,'_z',j,'.tif');
        imwrite(stack(:,:,i,j), name);
    end
end
