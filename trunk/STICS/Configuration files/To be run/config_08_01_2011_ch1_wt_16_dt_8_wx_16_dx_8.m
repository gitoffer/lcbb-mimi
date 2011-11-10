%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Config file for running STICS						%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% author = xies

%%%%%%%%%%%%%%%%%% Input file %%%%%%%%%%%%%%%%%%%%%%%

folder_stem = '~/Desktop/Mimi/Data/08-01-2011/';
imname = 'SqhGFPGap43mCherrytwiRNAi4_gauss';
file_ext = 'tif';
file_name = [folder_stem, imname,'.',file_ext];
custom = '';

%%%%%%%%%%%%%%%%%% Image information %%%%%%%%%%%%%%%%
num_frames = 249; %per channel
channels = 2;
im0 = imread(file_name );

%%%%%%%%%%%%%%%%%% Cropping image %%%%%%%%%%%%%%%%%%%
[Y,X,T,C] = size(im0);
x0 = 300;
xf = 700;
y0 = 1;
yf = Y;
t0 = 1;
t_f = 200;
ch = 1;

%%%%%%%%%%%%%%%%%% STICS options %%%%%%%%%%%%%%%%%%%%
um_per_px = 0.163; %um
sec_per_frame = 3; %sec
dt = 1;
wt = 16;
dx = 8;
dy = 8;
wx = 16;
wy = 16;
corrTimeLim = 3;
origial_dimensions = [X,Y,T];
crop = [x0,xf,y0,yf,t0,t_f,ch];
bayes = 0;

o = stics_option(im0,um_per_px,sec_per_frame,dt,wt,dx,dy,wx,wy,corrTimeLim,origial_dimensions,crop,ch,bayes);