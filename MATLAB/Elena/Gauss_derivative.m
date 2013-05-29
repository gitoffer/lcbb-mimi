function [ K  ] = Gauss_derivative( data , h,x )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


nums = data(~isnan(data));
n = length(nums);
K = zeros(size(x));
for i=1:n
    params = [1/sqrt(2*pi*h), nums(i), h]; 
    K = K + lsq_gaussderiv(params, x);
end


