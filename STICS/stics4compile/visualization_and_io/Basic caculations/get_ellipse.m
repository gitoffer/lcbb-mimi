function [X,Y] = get_ellipse(x,y,a,b,psi,n)
% Returns an ellipse centered at (x,y) with semimajor axes
% a and b with rotation from x-axis given by psi.
% Optional argument on sampling coarseness


error(nargchk(5, 6, nargin));
if nargin < 6
    n = 36;
end

theta = -psi ;
sintheta = sin(theta);
costheta = cos(theta);

phi = linspace(0, 2*pi, n)' ;
sinphi = sin(phi);
cosphi = cos(phi);

X = x + (a*cosphi*costheta - b*sinphi*sintheta);
Y = y + (a*cosphi*sintheta - b*sinphi*costheta);

if nargout == 1
    X = [X Y];
end

end