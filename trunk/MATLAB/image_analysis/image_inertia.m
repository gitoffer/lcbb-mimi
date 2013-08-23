function rho = image_inertia(img,mask,debug)
%IMAGE_INERTIA Find the inertial moment around the center of mass for a 2D image.
%
% SYNOPSIS: rho = image_inertia(img,mask)
%
% INPUT: img - binary or grayscale image
%        mask - maximum mask (for normalization)
%
% OUTPUT: rho - moment of inertia
%
% xies@mit Aug 2013

if nargin < 2, mask = ones(size(img)); debug = 0; end
if nargin < 3, debug = 0; end

% set up coordinate system (MATLAB IJ default)
[M,N] = size(img);
[X,Y] = meshgrid(1:N,1:M);

% find center of mass
cell_mass = sum(img(img > 0));
meanx = sum(sum( img.*X ))/cell_mass;
meany = sum(sum( img.*Y ))/cell_mass;

if debug
    figure,imshow(img,[]),hold on,plot(meanx,meany,'r*');hold off;
end

% reset coordinates wrt CoM
X = X - meanx;
Y = Y - meany;
% get radii at each pixel
R2 = X.^2 + Y.^2;

% get max R2
% edge = bwmorph(mask,'remove');
% maxR2 = mean(mean(edge.*R2));

% calculate rotation moment (rho)
rho = sum(sum( R2 .* (img)));
% normalize by max MR^2
rho = rho / sum(sum(img));
rho = rho / numel(mask(mask > 0));
% rho = rho / maxR2;

% rho = 1 - rho;

end