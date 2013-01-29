function [X,Y] = get_ellipse(x,y,a,b,psi,n)
%GET_ELLIPSE Given the center, the axes lengths, and the orientation, and
% the number of evaluation steps, yield the coordinates of an ellipse. The
% default coarseness is n = 36.
%
% USE: [X,Y] = get_ellipse(x,y,a,b,psi);
%      [X,Y] = get_ellipse(x,y,a,b,psi,n);
%      [coords] = get_ellipse(x,y,a,b,psi,n); where coords is a N by 2
%         matrix
%
% xies@mit.

error(nargchk(5, 6, nargin));
if nargin < 6, n = 36; end

theta = -psi ;
% Get sin/cos thetas.
sintheta = sin(theta);
costheta = cos(theta);

% Generate the 'contour length' of the parametrized ellipse.
phi = linspace(0, 2*pi, n)' ;
sinphi = sin(phi);
cosphi = cos(phi);

% Get coordinates.
X = x + (b*cosphi*costheta - a*sinphi*sintheta);
Y = y + (b*cosphi*sintheta + a*sinphi*costheta);

if nargout == 1, X = cat(2,X,Y); end

end