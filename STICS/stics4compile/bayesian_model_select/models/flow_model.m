function G = flow_model(params,coords,constants)

%CONVECTION_MODEL
% Theoretical STICS correlation function for pure convective phenomena.
% Written in the form that LSQCURVEFIT can accept, with two arguments, a
% cell array of parameters and a vector (matrix) of input.
%
% INPUT:  params 1 - G000
%                2 - G_inf
%                3 - vx
%                4 - vy
%               (5 - lambda)
%         coords   - lag variables scope and grain size
%         constants 1 - s, laser beam size / PSF size
%                   2 - um_per_px
%                   3 - sec_per_frame
%
% OUTPUT: G       - Correlation as a function of T

% Parameters to be fit
G000 = params(1);
G_inf = params(2);
vx = params(3);
vy = params(4);
% epx = params(5);
% epy = params(6);
% s = params(7);
epx = 0;epy = 0;

% Constants of imaging conditions
s = constants(1);
um_per_px = constants(2);
sec_per_frame = constants(3);

% If photobleaching time-scale is supplied, will multiply G by an overall
% exponential decay
if numel(params) == 8
    pb_flag = 1;
    lambda = params(8);
else
    pb_flag = 0;
end

% Lag bariables
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
Vx = vx(ones(1,n),ones(1,m),ones(1,numel(t)));
Vy = vy(ones(1,n),ones(1,m),ones(1,numel(t)));

G = G000.*exp(-((X+Vx.*T-epx).^2 + (Y + Vy.*T-epy).^2)/s^2);
if pb_flag, G = G.*exp(-T/lambda); end

% % Caculate G(eta,psi,tau) for all tau
% for i = 1:l
% 	G(:,:,i) = G000.*...
% 		exp(-((X+Vx*t(i)).^2+(Y+Vy*t(i)).^2)/s^2);
% 	if pb_flag
% 		G(:,:,i) = G(:,:,i).*exp(-t(i)/lambda);
% 	end
% end

% Unvectorized legacy code
% for i = 1:n
%     X = (i - floor(n/2))*um_per_px;
%     for j = 1:m
%         Y = (j-floor(m/2))*um_per_px;
%         G3(i,j,:) = G000...
%             .*exp(-((X+v(1)*t).^2+(Y+v(2)*t).^2)/s^2);
%         if pb_flag
%             G(i,j,:) = G(i,j,:).*exp(-t./lambda);
%         end
%     end
% end

% (tauf*128*rats*(a(1)+a(2))*ratt-tauf^2*ratt^2*a(1)*a(2)))

G = G + G_inf*ones(n,m,l);

end
