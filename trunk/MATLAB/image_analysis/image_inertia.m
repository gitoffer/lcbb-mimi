function rho = image_inertia(img,com,debug)
%IMAGE_INERTIA Find the inertial moment around the center of mass for a 2D image.
%
% SYNOPSIS: rho = image_inertia(img,com)
%
% INPUT: img - binary or grayscale image
%        com - (x,y) center of mass coordinates
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
meanx = com(1);
meany = com(2);

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

% normalize by total mass of image
rho = rho / sum(sum(img));
% normalize by number of pixels
rho = rho / numel(mask(mask > 0));
% normalize by max MR^2
% rho = rho / maxR2;

end