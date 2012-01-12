function [imgf,varargout] = gaussian_bandpass(img,support,sigma_lp,sigma_hp)
%GAUSSIAN_BANDPASS Performs Gaussian bandpass in spatial frequencies to get a
%filtered image. Performs filtering in the spectral domain.
%
% SYNOPSIS: imgf = gaussian_filter(img,100,1,5)
%           [imgf,kernel] = gaussian_filter(img,support,sigma_lp,sigma_hp)
% 
% INPUT: img - image to be filtered
%        support - support of the Gaussian kernel (assumed to be symmetric)
%        sigma_lp - Low pass frequency (if 0, no filtering will be done)
%        high_lp - High pass frequency (if 0, no filtering will be done)
%
% OUTPUT: imgf - filtered image
%         kernel - (optional) Returns the filter kernel
% xies@mit Nov 2011

support = int16(support);
[Y,X] = int16(size(img));

bg = zeros(support); %??
bg(fix(support-X/2 + 1:fix(support-X)/2 + X,...
    fix(support-Y/2)/2 + 1:fix(support-Y)/2 + Y)) = img;

[Xf,Yf] = meshgrid(1:support);
Xf = double(Xf - support/2 - 1);
Yf = double(Yf - support/2 - 1);

kernel = Xf*0;
if sigma_lp
    kernel = filtered + 1/(2*pi*sigma_lp^2)*exp(-(Xf.^2+Yf.^2)/2/sigma_lp^2);
else
    kernel(support/2 + 1, support/2 + 1) = 1;
end
if sigma_hp
    kernel = filtered - 1/(2*pi*sigma_hp^2)*exp(-(Xf.^2+Yf.^2)/2/sigma_hp^2);
end

imgf = real(ifft2(fft2(bg).*fft2(fftshift(kernel))));
imgf = imgf((support - X)/2+1 : (support - X)/2 + X,...
            (support - Y)/2+1 : (support - Y)/2 + Y);
kernel = kernel((support - X)/2 + 1 : (support - X)/2 + X,...
                  (support - Y)/2 + 1 : (support - Y)/2 + Y);

if nargout > 1
    varargout{1} = kernel;
end
 
end
