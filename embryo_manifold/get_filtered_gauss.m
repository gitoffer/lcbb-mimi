function [cellsf,filt] = get_filtered_gauss(cells,ext,slp,shp)

% Bandpass-filtering of image. In Fourier Domain. Returns filtered image
% and filter kernel.

ext=int16(ext);
a=int16(size(cells));

bg=zeros(ext);     % put on square array of size 2^N
bg(fix(ext-a(1))/2+1:fix(ext-a(1))/2+a(1),fix(ext-a(2))/2+1:fix(ext-a(2))/2+a(2))=cells;
%keyboard
[xx,yy] = meshgrid(1:ext,1:ext);   % koordinate system
xx=double(xx-ext/2-1);
yy=double(yy-ext/2-1);

% Gauss bandpass filter
filt=xx*0;
if (slp~=0)
    filt=filt+1/(2*pi*slp^2)*exp(-(xx.^2+yy.^2)/2/slp^2);
else
    filt(ext/2+1,ext/2+1)=1;
end
if (shp~=0)
    filt=filt-1/(2*pi*shp^2)*exp(-(xx.^2+yy.^2)/2/shp^2);
end


% filtering in Fourier domain
cellsf=real(ifft2(fft2(bg).*fft2(fftshift(filt))));
cellsf=cellsf((ext-a(1))/2+1:(ext-a(1))/2+a(1),(ext-a(2))/2+1:(ext-a(2))/2+a(2));
filt=filt((ext-a(1))/2+1:(ext-a(1))/2+a(1),(ext-a(2))/2+1:(ext-a(2))/2+a(2));
