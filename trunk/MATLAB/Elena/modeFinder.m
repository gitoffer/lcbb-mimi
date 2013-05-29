function [ modes ] = modeFinder( rowVector )
%UNTITLED Summary of this function goes here
%  input row vector
%tells you the number of zeroes; (mode finder) 

modes = 0;
n = length(rowVector);
if rowVector(1) > 0
    p = 1;
else
    p = 0;
end

for i=2:n
    q = p;
    if rowVector(i) == 0 
        modes = modes + 1;
    end
    if rowVector(i) > 0
        p = 1;
    else  
        p = 0;
    end
    
    if p ~= q
        modes = modes+1;
    end
     


end

