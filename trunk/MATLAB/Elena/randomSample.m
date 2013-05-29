function [ outMat ] = randomSample( data ,sampleSize )
%takes an input of a matrix and sample size(in elements )  
%retrieves a random slice of areas  of size x 


outMat = [] ;
data = data(isfinite(data));
lin = data(:);
a = size(lin);
b = a(1);
r = randi(b, sampleSize,1); 
for i =1:length(r)
    outMat = [outMat data(r(i))];
end
