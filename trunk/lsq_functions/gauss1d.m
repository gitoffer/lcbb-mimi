function y = gauss1d(params,x)

A = params(1);
mu = params(2);
sigma = params(3);
y = A.*exp(-(x-mu).^2/(2*sigma^2));