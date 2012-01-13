function im = imread_multi(filename,channels,z,num_frames)
%IMREAD_MULTI Reads in a multidimensional TIF image stack.
%
% SYNOPSIS: im = imread_multi(filename,num_frames,channels)
%
% INPUTS: filename - image file to be read-in
%         channels - number of channels
%         z - z slices
%         num_frames - number of total frames (per channel) in image
%
% xies@mit.edu

im0 = imread(filename);
im = zeros([size(im0),channels,z,num_frames]);

for k = 1:channels
    for j = 1:z
        for i = 1:num_frames
            im(:,:,k,j,i) = (i + z*(j-1) + channels*(k-1));
            im(:,:,k,j,i) = mat2gray(im(:,:,k,j,i));
        end
    end
end