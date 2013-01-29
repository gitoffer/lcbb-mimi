close all
%clear all
addpath('D:\network_simulator_0.2')
addpath('D:\network_simulator_0.2\simulator')
addpath('D:\network_simulator_0.2\utils')
addpath('D:\network_simulator_0.2\tools_jun')
addpath('D:\ICSMATLAB')
addpath('D:\ICSMATLAB\ICS')
addpath('D:\ICSMATLAB\imageManipulation')
%addpath('D:\ICSMATLAB\simul8tr') % not using the old simulator
addpath('D:\ICSMATLAB\STICS')
addpath('D:\ICSMATLAB\TICS')


%%%%%%%%%%%%%%%%%% actin worm %%%%%%%%%%%%%%%%
num_frames = 686;
file_name = 'D:\Data\LifeactGFP_2_1s_ORIGINALMOVIE.tif';
im0 = imread(file_name );
im = zeros([size(im0),num_frames]);
for j=1:num_frames
im(:,:,j) = imread(file_name ,j);
end
%imsequence_play(im)
% figure(1)
% imshow(im(:,:,1),[])
% hold on 
% plot(516,109,'.')
imcrop = im(109:172,516:579,:);
% play_stack(imcrop)
% clear im

o.im = imcrop;
o.um_per_px = 0.15; %um
o.sec_per_frame = 5; %sec
o.dt = 2;
o.wt = 20;
o.dx = 8;
o.dy = 8;
o.wx = 16;
o.wy = 16;
o.corrTimeLim = 6;

save('data','o')
