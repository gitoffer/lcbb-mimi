function y = lsq_exponential(params,t)
% For use by LSQ functions

A = params(1);
lambda = params(2);
offset = params(3);

y = A*exp((t)/lambda) + offset;

end
