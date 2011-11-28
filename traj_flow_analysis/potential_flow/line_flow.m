function [W,varargout] = line_flow(gamma,a,phi,x,y)
%SOURCE_SINK_SWIRL Generates the streamline function for a
% source/sink/swirl, with singularity at zA.
%
% SYNOPSIS: [W,X,Y] = source_sink_swirl(gamma,zA,x)
% INPUT: gamma - magnitude of the source/sink (c.f. charge). For a
%                source/sink, gamma is real and > 0 for a source, <0 for a
%                sink. For a swirl, gamma is imaginary.
%        zA - location in complex plane
%        x (optional) - grid on which to generate the field. Default is
%                       -10:.5:10
% OUTPUT: W - the flow potential
%         X,Y (optional) - the meshgrid coordinates of W
%
% xies@mit.edu. Nov 2011.

if ~exist('x','var'), x = -10:.5:10; end
if ~exist('y','var'), y = x; end
[X,Y] = meshgrid(x,y);

z = X + Y*1i;

W = gamma*sinc(a*z)*exp(1i*phi);
W = sum(W,3);

if nargout > 1
    varargout{1} = X;
    varargout{2} = Y;
end