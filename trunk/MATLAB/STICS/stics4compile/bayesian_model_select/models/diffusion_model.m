function G = diffusion_model(params,coords,constants)

%DIFFUSION
% Theoretical STICS correlation function for phenomena with pure diffusion.
% Written in the form that LSQCURVEFIT can accept, with two arguments, a
% vector of parameters and a vector (matrix) of input.
%
% INPUT:  params 1 - G000
%                2 - G_inf
%                3 - D
%               (4 - lambda)
%         coords   - lag variable scope and grain-size
%         constants 1 - s, laser beam size / PSF size
%                   2 - um_per_px
%                   3 - sec_per_frame
%
% OUTPUT: G       - Correlation as a function of T

% Parse parameters
G000 = params(1);
G_inf = params(2);
D = params(3);
% epx = params(4);
% epy = params(5);
% s = params(6);
epx = 0;epy = 0;

s = constants(1);
um_per_px = constants(2);
sec_per_frame = constants(3);

% Photobleaching
if numel(params) == 7
    pb_flag = 1;
    lambda = params(7);
else
    pb_flag = 0;
end

tD = s^2/4/D;

% Parse xdata
%x0 = coords(1,1); dx = coords(1,2); xf = coords(1,3);
%y0 = coords(2,1); dy = coords(2,2); yf = coords(2,3);
%t0 = coords(3,1); dt = coords(3,2); tf = coords(3,3);
%t = t0:dt:tf;
%t = t'*sec_per_frame;

n = coords(1); m = coords(2); t0 = coords(3); l = coords(4);
t = t0:l;
t = t'*sec_per_frame;
T = zeros(n,m,l);

for i = 1:l
    T(:,:,i) = t(ones(1,n)*i,ones(1,m));
end

[X,Y] = meshgrid(((1:n)-floor(n/2)).*um_per_px,...
	((1:m)-floor(m/2)).*um_per_px);
X = X(:,:,ones(1,l));
Y = Y(:,:,ones(1,l));

G = G000.*exp(-((X-epx).^2 + (Y-epy).^2)/s^2./(1+T/tD))./(1+T/tD);
if pb_flag, G = G.*exp(-T/lambda); end

G = G + G_inf*ones(n,m,l);

end
