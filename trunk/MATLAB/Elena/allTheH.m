function [ hValues ] = allTheH( numTrials,data,sizeSample ,k)
%for every random sample of size k , appends the plot size to a list 

hValues = [] ;
for i=1:numTrials 
a = randomSample(data,sizeSample);
b = modalityTest(a,1:5000, k); 
hValues = [hValues b] ;
end

