% Demo of "Region Based Active Contours"
%
% Example:
% seg_demo
%
% Coded by: Shawn Lankton (www.shawnlankton.com)

I = imread('airplane.jpg');  %-- load the image
m = zeros(size(I,1),size(I,2));          %-- create initial mask
m(111:222,123:234) = 1;

I = imresize(I,.5);  %-- make image smaller 
m = imresize(m,.5);  %     for fast computation

subplot(2,2,1); imshow(I); title('Input Image');
subplot(2,2,2); imshow(m); title('Initialization');
subplot(2,2,3); title('Segmentation');

seg = region_seg(I, m, 250); %-- Run segmentation

subplot(2,2,4); imshow(seg); title('Global Region-Based Segmentation');


