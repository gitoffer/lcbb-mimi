function F = convolveB3AWT(I, k)
%CONVOLVEB3AWT Convolve 3-spline interpolation of the Gaussian for the
%analytic wavelet transform.
%
% SYNOPSIS: F = convolveB3AWT(I,k);
%
% INPUT: I - image
%        k - the size of the Gaussian
% OUTPUT: F - Low-passed image
%
% Francois Aguet for CIAN 2011
[N, M] = size(I);
k1 = 2^(k - 1);
k2 = 2^k;

tmp = padarray(I, [k2 0], 'replicate');

% Convolve the columns
for i = k2+1:k2+N
    I(i - k2, :) = 6*tmp(i, :) + 4*(tmp(i + k1, :) + tmp(i - k1, :))...
                   + tmp(i + k2, :) + tmp(i - k2, :);
end

tmp = padarray(I * .0625, [0 k2], 'replicate');

% Convolve the rows
for i = k2+1:k2+M
    I(:, i - k2) = 6*tmp(:, i) + 4*(tmp(:, i + k1) + tmp(:, i - k1))...
                   + tmp(:, i + k2) + tmp(:, i - k2);
end
F = I * .0625;
