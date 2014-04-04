function [xp,yp] = shrink_polygon(x,y,scale)
%SHRINK_POLYGON Shrinks an irregular polygon by a scale given its vertices.
% NB: Scale here scales against area, so the vertices are scaled by
% \sqrt(scale).
% 
% USAGE: [xn,yn] = shrink_polygon(x,y,scale)
%
% xies@mit.edu

scale = sqrt(scale);

% Re-center
cx = mean(x);
cy = mean(y);

xp = x - cx;
yp = y - cy;

xp = xp * scale + cx; yp = yp * scale + cy;

end