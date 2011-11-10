function [V] = velocity_simple(peak_coord,dt,um_per_pix, frameLimit)
% From the original Kolin-Wiseman codeui
% 
% 
t = (1:size(peak_coord,1))'*dt;

% Calculates speed and direction given the coefficients of the 2D fits

% Filters immobile fraction
%    image_data = immfilter(image_data);


% Prompts user to select end of non noisy data

% close;
% xlin and ylin are the coordinates of a point outside the region of "nice" decay.
% So, any points with a t value less than xlim are in that region.
% t and Gtime are the "good" decay values.

%peak_coord = peak_coord(1:find(t<=xlim, 1, 'last' ),:);
%t = t(1:find(t<=xlim, 1, 'last' ),:);
regressionX = polyfit(t(1:frameLimit),peak_coord(1:frameLimit,1),1);
Vx = -regressionX(1);
regressionY = polyfit(t(1:frameLimit),peak_coord(1:frameLimit,2),1);
Vy = -regressionY(1);
V = [Vx Vy]*um_per_pix;