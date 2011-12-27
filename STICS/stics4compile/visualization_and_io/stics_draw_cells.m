function [F,stics_cells] = stics_draw_cells(image,stics_img,m,o,scaleFactor)
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

% STICS grid
EF = 2;
[Xf Yf] = grid4stics(image,o.dx,o.dy,o.wx,o.wy);
% Generate the correct time indexing vector
T = length(stics_img);
dt = o.dt;
wt = o.wt;
tbegin = max(ceil(dt/2),ceil(wt/2));
tend = numel(o.crop(5):o.crop(6)) - max(ceil(dt/2),ceil(wt/2));
t = tbegin : dt : tend;
I = floor(wt/2):numel(t);
j = 1:t(end) + floor(wt/2);
I_left = I(ones(1,floor(wt/2)-1));
I = [I_left,I];
I_right = I(ones(1,numel(j) - numel(I))*end);
I = [I,I_right];
stics_img = stics_img(I);

% Grab the grid vectors
X = numel(o.crop(1):o.crop(2));
Y = numel(o.crop(3):o.crop(4));

% Preallocate
num_cells = size(m(1).data,3);
stics_cells = cell(num_cells,T);
% Generate a colorset
colorset = varycolor(num_cells+3);
colorset = colorset(1:num_cells,:,:);
colorset = colorset(randperm(num_cells),:,:);

clear F
for i = 1:t(end) + floor(wt/2)
    imshow(imresize(image(:,:,i),EF),[]);
    hold on
    for j = 1:num_cells
        mask = make_cell_mask(m,i,1,j,X,Y,o.um_per_px);
        Vc = mask_vectorfield(stics_img{i},Xf,Yf,mask)*scaleFactor;
        stics_cells{i,j} = Vc;
        Vc(Vc == 0) = NaN;
        quiver(Xf*EF,Yf*EF,Vc(:,:,1),Vc(:,:,2),'Color',colorset(j,:,:),'linewidth',1.5);
    end
    F(i) = getframe;
    hold off
end
movie(F);

end