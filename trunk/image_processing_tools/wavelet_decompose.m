function [coeff,As] = wavelet_decompose(im,N)

coeff = zeros([size(im),N]);

for i = 1:N
    g = fspecial('gaussian',7*i,i);
    filtered = imfilter(im,g,'symmetric');
    
    sub = im - filtered;
    coeff(:,:,i) = sub;
    
    im = filtered;
end
As = im;