function [params]= polyGen ( data, toi )
%POLYGEN Wrapper for POLYFIT that crops the data
% at a splitting time TOI.
% INPUT: Data - data to be fitted
%        TOI - splitting time (frames after TOI are fitted)
% OUTPUT: p - polynomial parameters

[A,Y] = size(data) ;
x = toi:A ;
means = nanmean(data,2);
y = means(toi:A)';
idx = ~isnan(y);
y = y(idx);
x = x(idx);
 
%params = polyfit(x,y,1);



% x is a vector of [toi, toi+1.... size(data)(1)]
% y is a vector of the averages 

early = data(1:toi, :);
earlymean =nanmean(nanmean(early(:)));

ymean = mean(y);
xmean = mean(x);
m = (ymean-earlymean)/(xmean-toi);
b = earlymean - toi*m ;
params = [m,b]; 
%coeff = polyfit([toi,xmean],[earlymean, ymean],1);

end
