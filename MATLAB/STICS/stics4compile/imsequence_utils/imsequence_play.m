function imsequence_play( imsequence,name,caxis)
%IMSEQUENCE_PLAY
% USE: imsequence_play(imsequence)
%      imsequence_play(imsequence,name)

% window_size = 256;



num_frame = size(imsequence,3);
maxI= nanmax(imsequence(:));
minI= nanmin(imsequence(:));
if nargin < 3, caxis = [minI maxI]; end
figure(1000);
% set(gca, 'units', 'pixels', 'Position', [0 0 window_size window_size]);
% set(gcf, 'units', 'pixels', 'Position', [250 250 window_size window_size]);

for j = 1:num_frame
    A= imsequence(:,:,j);
    imshow(A,caxis);
    axis xy;
    F(j) = getframe;
end
if nargin > 1, movie2avi(F,name,'fps',5); end

end