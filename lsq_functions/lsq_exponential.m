function y = lsq_exponential(params,t)
% For use by LSQ functions

A = params(1);
center = params(2);
lambda = params(3);

y = A*exp((t-center)/lambda);

end
