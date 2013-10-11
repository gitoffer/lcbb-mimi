function F = imsequence_play( imsequence,name,caxis)
%IMSEQUENCE_PLAY
% USE: imsequence_play(imsequence)
%      imsequence_play(imsequence,name)

% window_size = 256;

if nargin < 2, name = '~/Desktop/movie.avi'; end

num_frame = size(imsequence,3);
maxI= nanmax(imsequence(:));
minI= nanmin(imsequence(:));
if nargin < 3, caxis = [minI maxI]; end
fig = figure(1000);
% set(gca, 'units', 'pixels', 'Position', [0 0 window_size window_size]);
% set(gcf, 'units', 'pixels', 'Position', [250 250 window_size window_size]);

F = avifile(name,'compression','none');

for j = 1:num_frame
    A= imsequence(:,:,j);
    imshow(A,caxis);
    axis xy;
    F = addframe(F,fig);
end

F = close(F);

end