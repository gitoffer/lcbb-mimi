function [ K ] = gaussian_KDE( data , h,x )
% MYOSINSTATS 
% provides info on the distribution of myosin over a given time frame  
% USAGE:not used with any other function
% INPUT: ti - the first time interval (sec)
%        tf - the end time interval (sec)
%        myosin - a matrix in form (time, myosin) denoting the area of a
%        myosin over a given time 
%        time - a matrix of time distribution for time frames 
% OUTPUT: myosin matrix - histogram of the area distribution (matrix) 
% elenad@mit.edu February 2013

% logvec1 = (time > ti) ; 
% logvec2 = (time < tf); 
% logvec3  = logvec1 & logvec2; 
% 
% desired_time = time.*logvec3 ;
% indices = find(desired_time); 
% int = length(indices); 
% 
% nums = data(indices(1): indices(int),:); % takes the areas across the given inputs of time  
nums = data(~isnan(data));
n = length(nums);
K = zeros(size(x));
for i=1:n
    params = [1/sqrt(2*pi*h), nums(i), h]; 
    K = lsq_gauss1d(params, x);
end


