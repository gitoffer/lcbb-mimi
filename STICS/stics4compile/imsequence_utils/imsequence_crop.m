function imsequence_cropped = imsequence_crop( imsequence)
figure(400)
imsequence_mean = mean(imsequence,3);
if  ndims(imsequence)==4
    imsequence_mean = mean(imsequence_mean,4);
end

imshow(imsequence_mean,[])
title('Please selet ROI to crop...','BackgroundColor','r','FontSize',10)%% crop image

rect = getrect;
hold on
plot(rect(1) ,  rect(2),'.')
plot(rect(1)+rect(3) ,  rect(2)+rect(4),'.')

imsequence_cropped = imsequence(floor(rect(2):rect(2)+rect(4)),floor(rect(1):rect(1)+rect(3)),:,:); 


% older code (slow) 
%
% B = imcrop(imsequence(:,:,1), rect);
% imsequence_cropped = zeros(size(B,1), size(B,2), num_frame);
% h = fspecial('gaussian', 3, 1); % create a gaussian lowpass filter
% 
% for j = 1:num_frame
%     A =  imsequence(:,:,j);
%     B = imcrop(A, rect);
%     C = imfilter(B,h); % filter with gaussian lowpass filter
%     imsequence_cropped(:,:,j)= B; % none filtered crop
% %     figure(1001)
% %     hold on
% %     imshow(imsequence_cropped(:,:,j),[]);
%     F(j)=getframe;
%     %imwrite(imsequence_crop(:,:,j),[num2str(j),'.tif'],'tif')
% end
