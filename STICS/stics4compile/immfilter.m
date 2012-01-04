function mobile = immfilter(movie);
%IMMFILTER Immobile element removal filter.
% Applies FFT and remove the zero-frequency component
% from a movie.
%
% SYNOPSIS: mobile_movie = immfilter(movie);
%
% INPUT: movie - 3D array (x,y,t)
% OUTPUT: mobile - movie with immobile component removed
%
% smg@lcbb.mit

set(gcbf,'pointer','watch');
h = waitbar(0,'Fourier Filtering Immobile Population...');
moviefft = zeros(size(movie));
waitbar(1/3,h)
moviefft = fft(double(movie),[],3);
waitbar(2/3,h)
moviefft(:,:,1) = 0;
mobile = real(ifft(moviefft,[],3));

if ishandle(h)
close(h)
end
set(gcbf,'pointer','arrow');
