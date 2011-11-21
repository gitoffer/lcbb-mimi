function [STCorr,varargout] = stics(imgser,TauLimit)

% July 10, 2003
% David Kolin
% Calculates the full time correlation function given 3D array of image series

set(gcbf,'pointer','watch');
[X,Y,num_frame] = size(imgser);

% h = waitbar(0,'Calculating time correlation functions...');  % for wait bar 1
% fprintf(1, 'Computing STCorr Function ...\n')

% tau is the lag
% pair is the nth pair of a lag time
STCorr = zeros(X,Y,TauLimit);  % preallocates lagcorr matrix for storing raw time corr functions
ST_std = zeros(X,Y,TauLimit);
SeriesMean = squeeze(mean(mean(imgser)));

% only correlate intensity fluctuations - subtract mean intensity
% imgser_fluct = zeros(X,Y,num_frame);
for i = 1:num_frame
    imgser(:,:,i) = imgser(:,:,i) - SeriesMean(i);
end
% imgser_flut = imgser;

for tau = 0 : TauLimit-1
    lagcorr = zeros(X,Y,(num_frame-tau));
    for pair=1:(num_frame-tau) % old: pair=1:(size(imgser,3)-tau)
        lagcorr(:,:,pair) = fftshift(real(ifft2(fft2(imgser(:,:,pair)).*conj(fft2(imgser(:,:,(pair+tau)))))));
        % normalize
        lagcorr(:,:,pair) = lagcorr(:,:,pair)/SeriesMean(pair)/SeriesMean(pair+tau)./numel(SeriesMean(pair));
    end
    STCorr(:,:,(tau+1)) = mean(lagcorr,3);
    ST_std(:,:,(tau+1)) = std(lagcorr,0,3);
end

% if ishandle(h) %  % for wait bar 3
% close(h)
% set(gcbf,'pointer','arrow'); % for wait bar 4

if nargout > 1
    varargout{1} = ST_std;
end

end
%imsequence_surf(timecorr); %%%%%%%%%%%%% plotting STICS