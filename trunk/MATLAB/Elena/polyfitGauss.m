function [ vectorofpolys ] = polyfitGauss( data, h, x, roots )
% POLYFITGAUSS  
% returns a row vector that you use to get your polynomial approximation of
%        the kernal so you can differentiate it and such 
% USAGE: use with gaussian_KDE 
% INPUT: data- see gaussian_KDE 
%        h - see gaussian_KDE
%        x - see gaussian_KDE 
%        roots - number of roots you want in your polynomial
% OUTPUT: 2:roots matrix of the first and second derivative of the
%        polynomial approximation of the kernel 
% elenad@mit.edu March 2013


kernel_output = gaussian_KDE(data, h, x) ; 
xrangevector = 1:max(x);
vectorofpolys = polyfit(xrangevector, kernel_output, roots);
vectorofpolys = [vectorofpolys; polyder(polyfit(xrangevector, kernel_output, roots)) 0];
y = 1:.1:100;
f = polyval(vectorofpolys(2,:), y);

