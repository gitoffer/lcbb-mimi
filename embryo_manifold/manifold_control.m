% In the process of restructuring manifold code. Do not use. - xies Jan 2012

%EXTRACT DEPTH-MANIFOLD OF MYOSIN
%RETURN MEMBRANES,MYOSIN AND CADHERIN AT THAT DEPTH

%FOR EACH EMBRYO NEED TO DETERMINE CONVENIENT PARAMETERS!
% requieres embryo axis to lay horizontally (otherwise modify line ...)
% always control if manifold (indqf) is correct using
% d=indqf-indq, (d=smoothened-discrete data) - Deviations should be
% of order of fluctuations within a myosin blob

clear variables; clc; close all
% Image filename, with extension but no directory path
io.file='SqhGFP Gap43.tif';
% Directory path for image
io.path  = '~/Desktop/Mimi/Data/05-26-2011/';
% Directory path for target output images
io.write_path = '';
% Strings for writing/reading TIFF sequences
% io.tstr = '_t';
% io.zstr = '_z';
% io.cstr = '_ch';
% First image in sequence to analyse
io.t0 = 10;
% Last image in sequence to read
io.tf = 10;
% Processing parameters - mostly low-level
io.write2file = 1;

%% Image properties
im_params.X = 1000; % Image size
im_params.Y = 400;
im_params.Z = 7; % Total Z-slices
im_params.T = 300; % Total frames
im_params.num_channels = 2; % Number of channels
im_params.myo_ch = 1;
im_params.mem_ch = 2;

% Embryo-specific processing parameters (these need to be tweaked every time)
th_params.wx = 50;
th_params.wy = 50;
th_params.perc = 20; % Top percentile to threshold myosin
th_params.bin_number = 1000; % bin-number for CDF calculations
th_params.filter_size = 25; % Gaussian size for smoothing the thresholded myosin
th_params.prefilter = 0;
th_params.display = 'on';

% Smoothing filter size for blurring the discrete Z-index
manifold_params.support = 1024; % Kernel support size for Gaussian filters - powers of 2 for FFT fastness
manifold_params.smoothing = 15;
manifold_params.avg_slice = 4;
manifold_params.display = 'on'; % Turn on to visualize the manifold

% Membrane masking parameters
mem_params.mem_mask = 'off';
mem_params.mask_thickness = 5;
mem_params.display = 'off';

% Manifold extraction parameters
extract_params.n_levels = 5;
extract_params.interp = 'on';
extract_params.interp_alpha = .5; % Should be .5


% Read in the entire stack -- memory-intensitve, might want to do it
% piecewise?
% entire_stack = imread_multi([io.path io.file],im_params.num_channels,im_params.Z,im_params.T-100);

for t = io.t0: io.tf
    % 	input_data = load_stack4manifold(io,im_params,t);
    % 	raw_myosin = input_data{1};
    % 	raw_membrane = input_data{2};
    raw_myosin = squeeze(entire_stack(:,:,im_params.myo_ch,:,t));
    raw_membrane = squeeze(entire_stack(:,:,im_params.mem_ch,:,t));
    
    if strcmpi(mem_params.mem_mask,'on')
        raw_myosin = make_mem_mask(raw_membrane, ...
            raw_myosin,im_params,mem_params);
    end
    
    % Find local thresholds
    local_thresholds = threshold_stack4manifold(raw_myosin, ...
        th_params);
    local_thresholds = local_thresholds(:,:,ones(1,im_params.Z));
    % Threshold myosin
    myosin_thresh = raw_myosin.*(raw_myosin > local_thresholds);
    keyboard;
    
    % Generate manifold
    manifold = get_manifold(myosin_thresh,manifold_params,im_params);
    keyboard
    
    % Use manifold to get myosin/membrane signal
    myosin_manifold = get_int_around_manifold(raw_myosin,manifold,extract_params,im_params);
    membrane_mnifold = get_int_around_manifold(raw_mem,manifold,extract_params,im_params);
    
    keyboard;
    
end

%%%%%%%%%%%%

%% GET Myosin Actin and Cadherin around MyosinDepth Manifold

%%
if WRITE_TO_FILE==1
    for n=1:11
        ii=n-1;
        jstr=int2str(ii);
        if (n < 11)
            jstr=strcat('0',jstr);
        end
        imwrite(uint8(Amyo(:,:,n)),[targ_dir,'actin_proj/',file,jstr,'_ch02.tif'],'tif');
        imwrite(uint8(Mmyo(:,:,n)),[targ_dir,'myosin_proj/',file,jstr,'_ch00.tif'],'tif');
        imwrite(uint8(Cmyo(:,:,n)),[targ_dir,'cadherin_proj/',file,jstr,'_ch01.tif'],'tif');
        imwrite(uint8(Cmyo(:,:,n)),[targ_dir,'alltogether/',file,jstr,'_ch01.tif'],'tif');
        imwrite(uint8(Mmyo(:,:,n)),[targ_dir,'alltogether/',file,jstr,'_ch00.tif'],'tif');
        imwrite(uint8(Amyo(:,:,n)),[targ_dir,'alltogether/',file,jstr,'_ch02.tif'],'tif');
    end
end

