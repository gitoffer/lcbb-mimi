function y = lsq_gauss1d(params,x)
%Intended for use with the OPTIMIZATION TOOLBOX, especiallu LSQCURVEFIT.
% SYNOPSIS: y = lsq_gauss1d(params,x)
% INPUT: params: [Amplitude mean standard_deviation];
%        x - the "domain"

A = params(1);
mu = params(2);
sigma = params(3);
y = A.*exp(-(x-mu).^2/(2*sigma^2));

end

