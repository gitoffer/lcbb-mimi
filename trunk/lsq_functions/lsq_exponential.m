function y = lsq_exponential(params,t)
% For use by LSQ functions

A = params(1);
lambda = params(2);

y = A*exp(-t/lambda);

end
