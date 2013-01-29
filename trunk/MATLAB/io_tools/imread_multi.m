function im = imread_multi(filename,channels,z,num_frames,convert)
%IMREAD_MULTI Reads in a multidimensional TIF image stack in CZT
%format.
%
% SYNOPSIS: im = imread_multi(filename,channels,z,num_frames)
%
% INPUTS: filename - image file to be read-in
%         channels - number of channels
%         z - z slices
%         num_frames - number of total frames (per channel) in image
%
% xies@mit.edu

im0 = imread(filename);
im = zeros([size(im0),channels,z,num_frames]);
if ~exist('convert','var'), convert = 'off'; end
index = 0;
for i = 1:num_frames
    for j = 1:z
        for k = 1:channels
            index = index + 1;
            im(:,:,k,j,i) = imread(filename,index);
            if strcmpi(convert,'on')
                im(:,:,k,j,i) = mat2gray(im(:,:,k,j,i));
            end
        end
    end
end

end
