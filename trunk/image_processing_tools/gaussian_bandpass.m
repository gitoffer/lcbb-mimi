function [imgf,varargout] = gaussian_bandpass(img,support,sigma_lp,sigma_hp)
%GAUSSIAN_FILTER Performs Gaussian bandpass in spatial frequencies to get a
%filtered image. Performs filtering in the frequency domain.
%
% SYNOPSIS: imgf = gaussian_filter(img,support,sigma_lp,sigma_hp)
%           [imgf,kernel] = gaussian_filter(img,support,sigma_lp,sigma_hp)
% 
% INPUT: img - image to be filtered
%        support - support of the Gaussian kernel (assumed to be symmetric)
%        sigma_lp - Low pass frequency (if 0, no filtering will be done)
%        high_lp - High pass frequency (if 0, no filtering will be done)
%
% OUTPUT: imgf - filtered image
%         kernel - optional
% xies@mit Nov 2011
support = int16(support);
a = int16(size(img));
Y = a(1);
X = a(2);

% Zero-padd raw input image (by roughly half the support of the kernel)
bg = zeros(support);
bg(fix((support-Y)/2) + 1:fix((support-Y)/2) + Y,...
    fix((support-X)/2) + 1:fix((support-X)/2) + X) = img;
[Xf,Yf] = meshgrid(1:support);
Xf = double(Xf - support/2 - 1);
Yf = double(Yf - support/2 - 1);

filtered = Xf*0;
if sigma_lp
    kernel = filtered + 1/(2*pi*sigma_lp^2)*exp(-(Xf.^2+Yf.^2)/2/sigma_lp^2);
else
    kernel(support/2 + 1, support/2 + 1) = 1;
end
if sigma_hp
    kernel = filtered - 1/(2*pi*sigma_hp^2)*exp(-(Xf.^2+Yf.^2)/2/sigma_hp^2);
end

% Multiply in frequency domain
imgf_freq = fft2(bg).*fft2(fftshift(kernel));
% Inverse Fourier transform, take only real component
imgf = real(ifft2(imgf_freq));

% Get rid of boundaries
imgf = imgf(fix((support - Y)/2)+1 : fix((support - Y)/2) + Y, ...
            fix((support - X)/2)+1 : fix((support - X)/2) + X);
kernel = kernel(fix((support - Y)/2) + 1 : fix((support - Y))/2 + Y, ...
                fix((support - X)/2) + 1 : fix((support - X))/2 + X);

if nargout > 1
    varargout{1} = kernel;
end

end