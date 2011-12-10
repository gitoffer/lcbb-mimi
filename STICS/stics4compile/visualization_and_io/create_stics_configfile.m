function create_stics_configfile

% Header
username = input('Please enter your name: ','s');
header = sprintf('%s\n%s\n%s\n%s%s\n', ...
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%', ...
    '% Config file for running STICS                     %', ...
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%', ...
    '% author = ', username ...
    );

% Input file information
display('Pick the image to be analyzed:');
[imname,folder_stem] ...
    = uigetfile({'~/Desktop/*.tif;*.tiff','All TIF images (*.tif, *.tiff)'}, ...
    'Pick the image to be analyized');
if imname == 0, error('User cancelled operation.'); end
[~,imname,file_ext] = fileparts(imname);
custom = input('Custom file name addendum (return if none): ','s');
input_file = sprintf('%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s\n%s%s%s\n', ...
    '%%%%%%%%%%%%%%%%%% Input file %%%%%%%%%%%%%%%%%%%%%%%', ...
    'folder_stem = ''', folder_stem, ''';',...
    'imname = ''', imname, ''';', ...
    'file_ext = ''', file_ext, ''';', ...
    'file_name = [folder_stem, imname, ''.'' file_ext];', ...
    'custom = ''', custom, ''';' ...
    );

% Image information
num_frames = input('How many frames (per channel) are there in the image stack? ','s');
channels = input('How many channels are in the image stack? ','s');

image_info = sprintf('%s\n%s%s%s\n%s%s%s\n%s\n',...
    '%%%%%%%%%%%%%%%%%% Cropping image %%%%%%%%%%%%%%%%%%%', ...
    'num_frames = ', num_frames, ';', ...
    'channels = ', channels, ';', ...
    'im = imread_multi(filename,num_frames,channels);' ...
    );

% Cropping image
needinput = 1;
while needinput
    crop = input('Do you want to crop the image? [y/n]: ','s');
    needinput = ~any(strcmpi(crop,{'y','n'}));
end
if strcmpi(crop,'y')
    x0 = input('Enter left edge of cropped image (enter ''1'' for leftmost of image): ','s');
    xf = input('Enter right edge of cropped image (enter ''X'' for rightmost of image): ','s');
    y0 = input('Enter top edge of cropped image (enter ''1'' for topmost of image): ','s');
    yf = input('Enter bottom edge of cropped image (enter ''Y'' for bottommost of image): ','s');
    t0 = input('Enter start of cropped movie (enter ''1'' for beginning of movie): ','s');
    t_f = input('Enter end of cropped movie (enter ''T'' for end of movie): ','s');
else
    x0 = '1'; xf = 'X'; y0 = '1'; yf = 'Y'; t0 = '1'; t_f = 'T';
end
ch = input('Which channel do you want to analyze? (enter number) ','s');

cropping_info = sprintf('%s\n%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n', ...
    '%%%%%%%%%%%%%%%%%% Cropping image %%%%%%%%%%%%%%%%%%%', ...
    '[Y,X,T,C] = size(im)', ...
    'x0 = ', x0, ';', ...
    'xf = ', xf, ';', ...
    'y0 = ', y0, ';', ...
    'yf = ', yf, ';', ...
    't0 = ', t0, ';', ...
    't_f = ', t_f, ';', ...
    'ch = ', ch, ';' ...
    );

% STICS options
um_per_px = input('Enter the spatial resolution (um/pixel): ','s');
sec_per_frame = input('Enter the temporal resolution (sec/frame): ','s');
dt = input('Enter the STICS frame rate (recommended: 1): ','s');
dx = input('Enter the STICS grid spacing in x: ','s');
wt = input('Enter the STICS time window size (in frames): ','s');
wx = input('Enter the STICS space window size in x (in pixels): ','s');
needinput = 1;
while needinput
    symmetric = input('Should the x- and y-directions have the same STICS settings? [y/n]: ','s');
    needinput = ~any(strcmpi(symmetric,{'y','n'}));
end
if strcmpi(symmetric,'y')
    wy = wx;
    dy = dx;
else
    dy = input('Enter the STICS grid spacing in y: ','s');
    wy = input('Enter the STICS space window size in y (in pixels): ','s');
end
corrTimeLim = input('Enter the STICS correlation time limit (usually 3-8): ');
needinput = 1;
while needinput
    bayes = input('Perform bayesian analysis? [1 for yes, 0 for no]: ','s');
    needinput = any(strcmpi(bayes,{'1','0'}));
end
stics_options = sprintf('%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s%s%s\n%s\n%s\n%s%s%s\n', ...
    '%%%%%%%%%%%%%%%%%% STICS options %%%%%%%%%%%%%%%%%%%%',...
    'um_per_px = ', um_per_px, ';', ...
    'sec_per_frame = ', sec_per_frame, ';', ...
    'dt = ', dt, ';', ...
    'wt = ', wt, ';', ...
    'dx = ', dx, ';', ...
    'wx = ', wx, ';', ...
    'dy = ', dy, ';', ...
    'wy = ', wy, ';', ...
    'corrTimeLim = ', corrTimeLim, ';', ...
    'origional_dimensions = [X,Y,T];', ...
    'crop = [x0,xf,y0,yf,t0,t_f,ch]', ...
    'bayes = ', bayes, ';' ...
    );

display('Save the newly created config file to...');
[config_file,config_path] = uiputfile('*.m','Save configuration file to...');
fid = fopen([config_path config_file],'w');
fprintf(fid,'%s\n%s\n%s\n%s\n%s\n',...
    header, input_file, image_info, cropping_info, stics_options ...
    );

display(['Configuration file saved at ' config_path config_file]);
end

