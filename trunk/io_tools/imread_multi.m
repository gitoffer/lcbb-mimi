function im = imread_multi(filename,num_frames,channels)
%IMREAD_MULTI Reads in a multidimensional image stack.
%
% SYNOPSIS: im = imread_multi(filename,num_frames,channels)
%
% INPUTS: filename - image file to be read-in
%         num_frames - number of total frames (per channel) in image
%         channels - number of channels (default is 1 if not supplied)

if ~exist('channels','var')
    channels = 1;
end

im0 = imread(filename);
im = zeros([size(im0),num_frames,channels]);


for j=1:channels
    for i = 1:num_frames
        im(:,:,i,j) = imread(filename , channels*(i-1)+(j));
        im(:,:,i,j) = mat2gray(im(:,:,i,j));
    end
end
clear im0r