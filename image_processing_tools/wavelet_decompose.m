function [coeff,As] = wavelet_decompose(im,s)

coeff = zeros([size(im),s]);

for i = 1:s
    filtered = convolveB3AWT(im,i); % Ai = filtered, Ai-1 = im
    coeff(:,:,i) = im - filtered;   % Wi = Ai-1 - Ai
    im = filtered;
end
As = im;