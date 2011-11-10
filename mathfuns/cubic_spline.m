function y = cubic_spline(t)
% CUBIC_SPLINE Spline approximation of a Gaussian.


x = abs(t);
I12 = (x>1) & (x<=2);
I01 = (x<=1);

y = I01.*(2/3 - x.^2.*(1-x/2)) + I12.*(1/6*(2-x).^3);
meshgrid(y,y);