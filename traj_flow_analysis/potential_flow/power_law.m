function [W,varargout] = power_law(mag,dir,power,x)
%POWER_LAW Generates streamline functions according to the powerlaw W =
%Az^n.
%
% SYNOPSIS: [W,X,Y] = power_law(mag,dir,power,x)
% INPUT: mag - magnitude of flow
%        dir - direction of attack
%        power - the power (1 - uniform)
%        x (optional) - spatial coordiates to generate W
% OUTPUT: W - potatial field
%         X,Y (optional) - coordinate system
%
% xies@mit.edu Nov 2011.


if ~exist('x','var'), x= -10:.5:10; end
[x,y] = meshgrid(x);

z = x + y*1i;

W = mag*exp(-1i*dir).*z.^power;


if nargout > 1
    varargout{1} = x;
    varargout{2} = y;
end