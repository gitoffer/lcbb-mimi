function imsequence = imsequence_load(filename_before_num ,filename_after_num, num_frame, varargin) %varargin == begin_frame(default =1),num_digits(default = 4)

begin_frame = 1; % beginning frame number, default = 1
num_digits = 4; %total number of digits in file name including 0's, defalt = 4
if ~isempty(varargin)
    begin_frame = varargin{1};
end

if size(varargin,2)==2
    num_digits = varargin{2};
end

%filename_before_num = 'D:\Data\09-8-12 RLC1 TOM d8s5 WELLS Zscan Timelaps\constricting ring timelapse 200msExposure bin4 1minDelay 1hour\JUN09-8_T';
%filename_after_num = '_568nm.tif';
num2str_format = ['%05.',num2str(num_digits),'d']; % 4 digits with empty position filled with '0's 

filename = [filename_before_num, num2str(begin_frame,num2str_format), filename_after_num]; % first image
A =  imread(filename);
imsequence = zeros(size(A,1),size(A,2),num_frame);
for j = 1:num_frame%% load and add image
    filename = [filename_before_num,num2str(j+begin_frame-1, num2str_format), filename_after_num];
    A =  imread(filename);
    imsequence(:,:,j)= A(:,:,1); % 
    %figure(101)
    %hold on
    %imshow(imsequence(:,:,j),[]);
end
mean_image = mean(imsequence,3);
imshow(mean_image,[])%% show added image
