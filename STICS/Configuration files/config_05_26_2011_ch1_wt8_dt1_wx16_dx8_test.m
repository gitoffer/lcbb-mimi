%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Config file for running STICS						%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% author = xies

%%%%%%%%%%%%%%%%%% Input file %%%%%%%%%%%%%%%%%%%%%%%

folder_stem = '~/Desktop/Mimi/Data/05-26-2011/';
imname = 'SqhGFPGap43_Maximumintensityprojection_gauss1';
file_ext = 'tif';
io.file_name = [folder_stem, imname,'.',file_ext];

%%%%%%%%%%%%%%%%%% Image information %%%%%%%%%%%%%%%%
num_frames = 249; %per channel
channels = 2;
im0 = imread(io.file_name );

%%%%%%%%%%%%%%%%%% Cropping image %%%%%%%%%%%%%%%%%%%
[Y,X,T,C] = size(im0);
x0 = 200;
xf = 250;
y0 = 150;
yf = 200;
t0 = 50;
t_f = 80;
ch = 1;

%%%%%%%%%%%%%%%%%% STICS options %%%%%%%%%%%%%%%%%%%%
um_per_px = 0.163; %um
sec_per_frame = 3; %sec
dt = 1;
wt = 8;
dx = 8;
dy = 8;
wx = 16;
wy = 16;
corrTimeLim = 3;
origial_dimensions = [X,Y,T];
crop = [x0,xf,y0,yf,t0,t_f,ch];

o = stics_option(um_per_px,sec_per_frame,dt,wt,dx,dy,wx,wy,corrTimeLim,origial_dimensions,crop);