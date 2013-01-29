function Vc = mask_vectorfield(V,Xf,Yf,mask)
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

x = Xf(1,:);
y = Yf(:,1);

grid_mask = mask;
grid_mask = grid_mask(y,x);
Vc = V.*grid_mask(:,:,[1 1]);

end