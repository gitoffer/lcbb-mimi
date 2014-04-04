function im_denoised = wavelet_denoise(im,s,cutoff)

[~,~,T] = size(im);
im_denoised = zeros(size(im));
for i = 1:T
    this_img = im(:,:,i);
    [coeff,As] = wavelet_decompose(this_img,s);
    im_denoised(:,:,i) = wavelet_coeff_denoise(coeff,As,cutoff);
end

end