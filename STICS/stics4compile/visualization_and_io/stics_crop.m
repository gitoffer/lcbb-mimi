function [cropped,Xfc,Yfc] = stics_crop(stics_img,Xf,Yf,crop)
%STICS_CROP Returns a sub-vector field of the original STICS vector field.
% SYNOPSIS: [stics_img,Xf,Yf] = stics_crop(stics_img,Xf,Yf,crop)
%
% INPUT: stics_img - original STICS field
%        Xf,Yf - original STICS mesh
%        crop - structure specifying the locations of the crop, with the
%               indices referring to the indices in the original intensity
%               image.
%             .x0 .xf .y0 .xf (.t0 .tf)
% OUTPUT: stics_img - cropped

x0 = crop.x0;
xf = crop.xf;
y0 = crop.y0;
yf = crop.yf;
if ~isfield(crop,'t0'), t0 = 1; else t0 = crop.t0; end
if ~isfield(crop,'tf'), tf = numel(stics_img); else tf = crop.tf; end

x = Xf(1,:);
y = Yf(:,1);
% imc = zeros(yf-y0+floor(x(1)/2),xf-x0+floor(x(1)/2),numel(stics_img));
x0 = x(x >= x0 & x < x0 + x(1));
xf = x(x >= xf & x < xf + x(1));
y0 = y(y >= y0 & y < y0 + y(1));
yf = y(y >= yf & y < yf + y(1));

x = x(:,find(x==x0):find(x==xf));
y = y(find(y==y0):find(y==yf),:);
[Xfc,Yfc] = meshgrid(x,y);

cropped = cell(numel(t0:tf),1);
for i = t0:tf
    vector = stics_img{i};
    cropped{i} = vector(find(y==y0):find(y==yf),find(x==x0):find(x==xf),:);
end