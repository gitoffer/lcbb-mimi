function [ kernel ] = allKernel( data )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%   INPUT- data in matrix form 
%   OUTPUT - silly little plot 
%   the internet, March, 2013

% does kernel regressions for all types of kernels: 

 hname = {'normal' 'epanechnikov' 'box' 'triangle'};
colors = {'r' 'b' 'g' 'm'};
for j=1:4
    [f,x] = ksdensity(data(:),'kernel',hname{j});
    kernel = plot(x,f,colors{j});
    hold on;
end
legend(hname{:});
hold off


end

