function imsequence_play( imsequence)
window_size = 256;

num_frame = size(imsequence,3);
maxI= max(imsequence(:));
minI= min(imsequence(:));
figure(1000);
% set(gca, 'units', 'pixels', 'Position', [0 0 window_size window_size]);
% set(gcf, 'units', 'pixels', 'Position', [250 250 window_size window_size]);

for j = 1:num_frame
    A= imsequence(:,:,j);
    imshow(A,[minI maxI]);
    F(j) = getframe;
end
movie2avi(F,'movie2','fps',5)
