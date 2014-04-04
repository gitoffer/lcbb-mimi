function [ I,h ] = kernelmi( x, y, h, ind )
% Kernel-based estimate for mutual information I(X, Y), using the
% Radial-basis kernel (RBK).
% h - kernel width; ind - subset of data on which to estimate MI

[Nx, Mx]=size(x);
[Ny, My]=size(y);

if any([Nx Ny My] ~= [1 1 Mx])
    error('X and Y must column vectors with the same dimensions.');
end

switch nargin
	case 2
    % Yields unbiased estiamte when Mx->inf 
    % and low MSE for two joint gaussian variables
    alpha = 0.25;
    h = (Mx + 1) / sqrt(12) / Mx ^ (1 + alpha);
    ind = 1:Mx;
	case 3
		ind = 1:Mx;
    case 4
	otherwise
		error('Wrong number of inputs.');
end

% Copula-transform variables
x = ctransform(x);
y = ctransform(y);

h2 = 2*h^2;

% Pointwise values for kernels
Kx = squareform(exp(-ssqd([x;x])/h2))+eye(Mx);
Ky = squareform(exp(-ssqd([y;y])/h2))+eye(Mx);

% Kernel sums for marginal probabilities
Cx = sum(Kx);
Cy = sum(Ky);

% Kernel product for joint probabilities
Kxy = Kx.*Ky;

f = sum(Cx.*Cy)*sum(Kxy)./(Cx*Ky)./(Cy*Kx);
I = mean(log(f(ind)));

end

