function [W,varargout] = vortex(gamma,a,zA,x)
%VORTEX Generates the flow potential for a vortex
%
% SYNOPSIS: [W,X,Y] = vortex(gamma,a,zA,x)
% INPUT: gamma - magnitude (real number)
%        a - ?
%        zA - location of one of the vortex centers
%        x (optional) - grid on which to generate the field. Default is
%                       -10:.5:10
% OUTPUT: W - the flow potential
%         X,Y (optional) - the meshgrid coordinates of W
%
% xies@mit.edu. Nov 2011.

if ~exist('x','var'), x = -10:.5:10; end

[x,y] = meshgrid(x);

z = x + y*1i;
W = 1i*gamma/(2*pi)*(-log(z-zA) + log(a^2./z-conj(zA)));

% w=1i*gamma/(2*pi)*(-log(z-Z)+log(a^2./z-conj(Z)));

if nargout > 1
    varargout{1} = Xf;
    varargout{2} = Yf;
end