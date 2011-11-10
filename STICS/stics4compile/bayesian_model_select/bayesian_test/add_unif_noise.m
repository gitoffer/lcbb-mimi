function f_err = add_unif_noise(f,sigma)

%ADD_UNIF_NOISE
% Adds uniform noise to the matrix f, where sigma denotes the absolute size
% of the noise floor.

epsilon = randn(size(f))*sigma;

f_err = f + epsilon;