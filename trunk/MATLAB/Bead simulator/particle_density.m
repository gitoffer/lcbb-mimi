function [rho_fit rho sigmas]= particle_density(f)
% Takes an image stack and determines the effective density 
% of independent brownian particles, in particles per pixel^2
%
% INPUT: f(y,x,t) -- image stack of real numbers
% OUPUT: estimate of the density, positive real number


Nx = min(size(f(:,:,1)));
sigmas = linspace(1, 5,5);

% make the images square
f = f(1:Nx, 1:Nx, :);

rho = zeros(size(sigmas));


fs = zeros(size(f));
filt = zeros(size(f,1), size(f,2));


for isigma = 1:length(sigmas)
   % convolve the image stack with a filter of known area
   filt = conj(fft2(fspecial('Gauss', Nx, sigmas(isigma))));
   for t = 1:size(f,3)
       fs(:,:,t) = fftshift(ifft2(fft2(f(:,:,t)).*filt))/(Nx^2);
   end
   C = real(corrfunc(fs));
   
   % multiply each C(t) by the mean intensity in the frame
   for t = 1:size(f,3)
        C(:,:,t) = C(:,:,t) .* mean(mean(fs(:,:,t)));
   end
  
   % estimate the coefficient on the exponential terms
   rho(isigma)  = range(C);
end

c = polyfit(pi*sigmas.^2, 1./rho,1);
rho_fit = c(1);
end