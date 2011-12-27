function [cropped] = stics_draw_mask(stics_img,Xf,Yf,mask,o)
%STICS_CROP_MAKS Returns a sub-vector field of the original STICS vector
%field according to a mask.
% SYNOPSIS: cropped = stics_crop(stics_img,Xf,Yf,mask,o)
%
% INPUT: stics_img - original STICS field
%        Xf,Yf - original STICS mesh
%        mask - mask of ROI over the original image
%        o - SticsOptions structure
% OUTPUT: cropped - cropped output
%
% xies@mit Dec 2011.

% Generate the correct time indexing vector
T = length(stics_img);
dt = o.dt;
wt = o.wt;
tbegin = max(ceil(dt/2),ceil(wt/2));
tend = size(mask,3) - max(ceil(dt/2),ceil(wt/2));
t = tbegin : dt : tend;

I = floor(wt/2):numel(t);
j = 1:t(end) + floor(wt/2);
I_left = I(ones(1,floor(wt/2)-1));
I = [I_left,I];
I_right = I(ones(1,numel(j) - numel(I))*end);
I = [I,I_right];

cropped = cell(1,T);
for i = 1:T
    cropped{i} = mask_vectorfield(stics_img{i},Xf,Yf,mask(:,:,I(i)));
end

end