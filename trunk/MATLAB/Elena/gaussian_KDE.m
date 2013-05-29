function [ K ] = gaussian_KDE( data , h, x ,deriv)
% GAUSSIAN_KDE
% returns a vector for points on the gaussian
% USAGE:not used with any other function
% INPUT: data - data set that you are using (matrix double form)
%        h - smoothing value- the lower the h-value, the more advantageous
%        x - a range in form int:int that is the range of the data. i.e. for areas its 1:100 for the most part, 1:3000 for myosins
% OUTPUT: row vector that you use with the plot function
% elenad@mit.edu February 2013

nums = data(~isnan(data));
n = length(nums);
K = zeros(size(x));

switch deriv
    case 0 % no derivaties
        for i=1:n
            params = [1/sqrt(2*pi*h), nums(i), h];
            K = K + lsq_gauss1d(params, x);
        end
    case 1
        for i=1:n
            params =[1/sqrt(2*pi*h), nums(i), h];
            K = K + lsq_gauss2d(params, x);
        end
        
end

end