function [f o] = lines_from_bonds(popu, o)

% This function creates a discretized images of bonds as lines
o  = check_field(o, 'points_per_line', 100);

% set up some convenient shortcuts
coord_field_names = {'x', 'y', 'z'};
Lpx = o.box_size_px;
L = Lpx*o.um_per_px;


% create bond pair indices
B1 = [];
B2 = [];

for icol = 1:size(popu.bonds, 2);
    B1 = [B1; (1:size(popu.bonds,1))'];
    B2 = [B2; popu.bonds(:,icol)];
end

% make the index pairs unique
i = (B1 < B2);
B1 = B1(i);
B2 = B2(i);


% calculate bond lengths
% r = r(bond index, dimension) is the set of bond vectors in row form stacked on top of
% each other
r = zeros(length(B1), o.n_dims);
%   calculate distances along each dimension
%   
x = popu.x;
for dim =1:o.n_dims
    r(:,dim) = x(B2,dim) - x(B1,dim) ;
    % apply peroidic boundary conditions    
    r(:, dim) = r(:,dim) - L(dim)*round(r(:,dim)/L(dim));
end

% convert the bond vectors to actual bond length
rabs = sqrt(sum(r.*r,2));


% calculate the point weights along the bonds
% make all the lines the same weight
lambdas = linspace(0, 1, o.points_per_line);

% 
% 
y = zeros(size(B1, o.n_dims));


%

f = zeros(Lpx(2), Lpx(1));
for n = 1:length(lambdas)
    % create the points
         y = x(B1,1:o.n_dims) + r(:,1:o.n_dims)*lambdas(n); % (1-lambdas(n)).*x(B2,:);

         % calculate the pixel positions corresponding to y
         iy = ceil(y/o.um_per_px);
         % correct them for boundary artifacts 
         for dim = 1:o.n_dims
             iy(:,dim) = iy(:, dim) + (iy(:,dim) < 1) .* Lpx(dim);             
             iy(:,dim) = iy(:, dim) - (iy(:,dim) > Lpx(dim)) .* Lpx(dim);
         end
         
         % add to the intensity of corresponding pixels
         % calculate the reduction in intensity due to the z-position
         w_depth = ones(size(r,1),1);
         if o.n_dims ==3
             w_depth =  exp(-(y(:,3)-L(3)/2).^2/(2*o.psf_sigma_um(3).^2)) ;
         end
         
         f = f + full(sparse(iy(:,2), iy(:,1), rabs.*w_depth, Lpx(2), Lpx(1)));  
    end
    
end