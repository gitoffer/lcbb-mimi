function [f o] = points_from_nodes(statex, o, varargin) % statex is the particle positions with dimensions(n,3)
% We assume that the image is cropped from the bottom left corner of the 
% simulation box, assuming periodic boundary conditions.
% Specifically,  assume that the image is at [0, Lpx(1)) x [0, Lpx(2) ), while the
% simulation system is at [0, o.sim_box_size_um(1)) x [0,
% o.sim_box_size_um(2))
% set up some convenient shortcuts
% 
% shortcut to box size dimension in pixels


Lpx = o.box_size_px;
% shortcut to box size in physical units
L = Lpx*o.um_per_px;

if isempty(varargin)% imaging depth, Z0=L(3)/2 by default
    Z0 = L(3)/2; 
else
    Z0 = varargin{1};
end


% calculate the pixel positions corresponding to the particles 
iy = ceil(statex/o.um_per_px);

% find the particles in the field of view
ivalid = ones(size(statex,1),1);
 for dim = 1:2
     % the pixel coordinate must be inside the closed interval [1, Lpx]
    ivalid = ivalid & (iy(:,dim) < Lpx(dim));
 end

iy = iy(ivalid,:);
% add to the intensity of corresponding pixels
%   allocate image storage
f = zeros(Lpx(2), Lpx(1));
%   calculate linear index to pixels
linear_index = iy(:,1)  + (iy(:,2)-1)*size(f,1);

%   add the contribution of each particle to the corresponding pixel
if o.n_dims == 2
    f(1:max(linear_index)) = accumarray(linear_index, 1.0);% reshape(histc(linear_index, 1:numel(f)), size(f));
elseif  o.n_dims ==3
    
%     if numel(linear_index) > 0.1*numel(f)
%         warning('%s: number of particles is close to the number of pixels. \n Algorithm may at overlapping particles.', mfilename);
%     end
    % calculate the reduction in intensity due to out-of-plane the z-position
    w =  1.0*exp(-(statex(ivalid,3) - Z0).^2/(o.psf_sigma_um(3).^2/2)) ; 
    f(1:max(linear_index)) = accumarray(linear_index, w);
end


