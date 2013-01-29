function G = noise_model(params,coords,varargin)

%NOISE_MODEL
% Theoretical form of STICS correlation function if there is only Gaussian
% noise.
%
% INPUT:  params 1 - size of noise floor
%         coords   - lag variable scope and grain-size
%
% OUTPUT: G       - Correlation as a function of T


G_inf = params(1);

n = coords(1); m = coords(2); t0 = coords(3); l = coords(4);

G = zeros(n,m,l);
G = G + G_inf*ones(n,m,l);

end