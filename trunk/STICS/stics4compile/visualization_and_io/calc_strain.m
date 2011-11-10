function e = calc_strain(U)
% Calculates the Eulerian (spatial) strain tensor, e, of a 2D vector field
% of displacement vectors, U. This is given by:
%       e = (1/2)*(del u + del' u)
%           = [du/dx    (dv/dx+du/dy)/2;
%              (dv/dx+du/dy)/2    dv/dy]
% where del is the gradient operator.

e = zeros([size(U(:,:,1)) 2 2]);
[Uxy, Uxx] = gradient(U(:,:,1));
[Uyy, Uyx] = gradient(U(:,:,2));

for i = 1:size(U,1)
    for j = 1:size(U,2)
        U_grad = [Uxx(i,j),Uxy(i,j);Uyx(i,j),Uyy(i,j)];
        e(i,j,:,:) = (U_grad+U_grad')/2;
    end
end
