function y = lsq_gauss2d(params,x)
%Intended for use with the OPTIMIZATION TOOLBOX, especiallu LSQCURVEFIT.
% SYNOPSIS: y = lsq_gauss2d(params,x)
% INPUT: params: [Amplitude mean standard_deviation];
%        x - the "domain"


A = params(1);
mu = params(2);
sigma = params(3);
y = (1/sigma^2)*(mu-x)*A.*exp(-((mu- x).^2)/(2*sigma^2));


end

