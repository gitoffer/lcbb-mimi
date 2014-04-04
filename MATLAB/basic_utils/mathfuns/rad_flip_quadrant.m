function flipped = rad_flip_quadrant(angles)
%RAD_FLIP_QUADRANT Makes angles in between 1 and 4-th quadrant. This useful
%if the angle represents a line and not a oriented direction. Assumes input
%is from atan2, i.e. -pi <= angeles <= pi
%
% xies@mit.edu Mar 2012.

second_quad = angles > 0 & angles > pi/2;
third_quad = angles < 0 & angles < -pi/2;

flipped = angles;
flipped(second_quad) = angles(second_quad)-pi;
flipped(third_quad) = pi+angles(third_quad);

flipped(flipped < 0) = -flipped(flipped < 0);

end