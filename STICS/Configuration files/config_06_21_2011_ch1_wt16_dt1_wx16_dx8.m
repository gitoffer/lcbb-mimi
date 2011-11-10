%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Config file for running STICS						%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% author = xies

%%%%%%%%%%%%%%%%%% Input file %%%%%%%%%%%%%%%%%%%%%%%

folder_stem = '~/Desktop/Mimi/Data/06-21-2011/';
imname = 'SqhGFPGap43Squashed2_Maximumintensityprojection_gauss';
file_ext = 'tif';
io.file_name = [folder_stem, imname,'.',file_ext];

%%%%%%%%%%%%%%%%%% Image information %%%%%%%%%%%%%%%%
num_frames = 249; %per channel
channels = 2;
im0 = imread(io.file_name );

%%%%%%%%%%%%%%%%%% Cropping image %%%%%%%%%%%%%%%%%%%
[Y,X,T,C] = size(im0);
x0 = 1;
xf = X;
y0 = 1;
yf = Y;
t0 = 20;
t_f = 200;
ch = 1;

%%%%%%%%%%%%%%%%%% STICS options %%%%%%%%%%%%%%%%%%%%
o.um_per_px = 0.163; %um
o.sec_per_frame = 3; %sec
o.dt = 1;
o.wt = 16;
o.dx = 8;
o.dy = 8;
o.wx = 16;
o.wy = 16;
o.corrTimeLim = 3;
o.dimensions = [X,Y,T];
o.crop = [x0,xf,y0,yf,t0,t_f,ch];