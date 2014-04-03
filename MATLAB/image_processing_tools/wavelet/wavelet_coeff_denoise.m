function im_denoised = wavelet_coeff_denoise(coeff,As,cutoff)
%WAVELET_DENOISE
%
% SYNOPSIS: im_denoised = wavelet_denoised(coeff,As)
%
% INPUT: coeff - wavelet coefficients
%        As - residual

[X,Y,N] = size(coeff);
coeff = reshape(coeff,X*Y,N);

% Use median absolute deviation, robust standard deviation estimator
sigmas = mad(coeff,0,1);
pixels_to_keep = coeff > cutoff*sigmas(ones(1,X*Y),:);
new_coeff = coeff.*pixels_to_keep;

new_coeff = reshape(new_coeff,X,Y,N);
im_denoised = wavelet_synthesize(new_coeff,As);

end