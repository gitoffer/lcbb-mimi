function varargout = ellipse(lx,ly,c_x,c_y,angle,colors,N)
% ELLIPSE Draws a filled-in ellipse using a polygon (patch object).
%
% SYNPSIS ellipse(major,minor,c_x,c_y,angle,color,N)
%
% INPUTS: lx - Length in x (unrotated)
%         ly - Length in y (unrotated)
%         c_x,c_y - Center coordinate
%         angle - Orientation in radians
%         color - Color to fill ellipse with in string or RGB
%         N (opt) - number of polygon sides, default is 300
% Inputs can be vectors.
% OUTPUT: Can optionally return a vector of handles of the ellipses.

if ~exist('N','var'), N = 300; end
num_ell = numel(lx);
thetas = linspace(0,2*pi + 0.1, N);

for i = 1:num_ell
    r = [(lx(i)*cos(thetas))' (ly(i)*sin(thetas))'];
    Rot= [cos(angle(i)) -sin(angle(i))
         sin(angle(i)) cos(angle(i))];
    r=r*Rot;
    h(i) = patch(c_x(i)+r(:,1),c_y(i)+r(:,2),colors(i,:),'EdgeColor',colors(i,:));
end

if nargout > 0
    varargout{1} = h;
end