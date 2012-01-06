function [coeff,As] = wavelet_decompose(im0,s)

% [N,M,T] = size(im);
coeff = zeros([size(im0),s]);
im = im0;

for i = 1:s
    filtered = convolveB3AWT(im,i); % Ai = filtered, Ai-1 = im
    coeff(:,:,i) = im - filtered;   % Wi = Ai-1 - Ai
    im = filtered;
end
As = im;