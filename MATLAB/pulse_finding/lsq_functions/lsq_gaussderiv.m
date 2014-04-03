function y = lsq_gaussderiv(params,x)
%Intended for use with the OPTIMIZATION TOOLBOX, especiallu LSQCURVEFIT.
% SYNOPSIS: y = lsq_gaussderiv(params,x)
% INPUT: params: [Amplitude mean standard_deviation];
%        x - the "domain"


A = params(1);
mu = params(2);
sigma = params(3);
y = A.*(x.^2 - 1).*exp(-(x-mu).^2/(2*sigma^2));

end

