%MANIFOLD_CONTROL
% Script to create a 'manifold' that captures the depth of intense myosin
% puncta and use the z-information to 'stretch out' the curved embryo.
%
% Usage:
% 1) Things that need to be tweaked everytime:
%       - io - file input/output
%       - im_params - basic information about image
%       - th_params - thresholding parameters for isolating myosin puncta
%       - manifold_params - smoothing and averaging parameters for
%         generating the smooth manifold
%       - extract_params - parameters on how to use the manifold to extract
%         information from stacks
% 2) Display control
%       - For a single stack: it is recommended that you turn on all
%          display flags, or, alternatively, turn on DEBUGGING.
%       - For a time-lapsed stack: it is recommended that you select some
%          slices to analyise in-depth for parameter selection with the
%          display/DEBUGGING turned on. And then for processing the entire
%          stack please turn display off.
%
% xies@mit Jan 2012.

clear variables; clc; close all
% Image filename, with extension but no directory path
io.file='SqhGFPmCherryGap43_7_tcrop.tif';
% Directory path for image
io.path  = '~/Desktop/Mimi/Data/01-30-2012/7/';
% Directory path for target output images
io.write_path = '~/Desktop/';
% Strings for writing/reading TIFF sequences
% io.tstr = '_t';
% io.zstr = '_z';
% io.cstr = '_ch';
% First image in sequence to analyse
io.t0 = 1;
% Last image in sequence to read
io.tf = 80;

io.write2file = 1;

%%
DEBUGGING = 0;

%% Image properties
im_params.X = 1000; % Image size
im_params.Y = 400;
im_params.Z = 10; % Total Z-slices
im_params.T = 80; % Total frames
im_params.num_channels = 2; % Number of channels
im_params.myo_ch = 1;
im_params.mem_ch = 2;
im_params.support = 1024*2;

% Embryo-specific processing parameters (these need to be tweaked every time)
th_params.Nx = 1;
th_params.Ny = 1;
th_params.perc = 1; % Top percentile to threshold myosin
th_params.bin_number = 500; % bin-number for CDF calculations
th_params.filter_size = 30; % Gaussian size for smoothing the thresholded myosin
th_params.prefilter = 1;
th_params.display = 'off';

% Smoothing filter size for blurring the discrete Z-index
manifold_params.support = 1024*2; % Kernel support size for Gaussian filters - powers of 2 for FFT fastness
manifold_params.smoothing = 20;
manifold_params.avg_slice = 4;
manifold_params.display = 'off'; % Turn on to visualize the manifold

% Membrane masking parameters
mem_params.mem_mask = 'off';
mem_params.mask_thickness = 5;
mem_params.display = 'off';

% Manifold extraction parameters
extract_params.n_levels = 2;
extract_params.interp = 'on';

%%
% Read in the entire stack -- memory-intensitve, might want to do it
% piecewise?
% entire_stack = imread_multi([io.path io.file],im_params.num_channels,im_params.Z,im_params.T);

myosinM = zeros(im_params.Y,im_params.X,2*extract_params.n_levels + 1,numel(io.t0:io.tf));
membraneM = zeros(im_params.Y,im_params.X,2*extract_params.n_levels + 1,numel(io.t0:io.tf));
fraction_found_myo = zeros(numel(io.t0:io.tf),1);
fraction_found_mem = zeros(numel(io.t0:io.tf),1);

for t = io.t0 : io.tf
    % 	input_data = load_stack4manifold(io,im_params,t);
    % 	raw_myosin = input_data{1};
    % 	raw_membrane = input_data{2};
    raw_myosin = squeeze(entire_stack(:,:,im_params.myo_ch,:,t));
    raw_membrane = squeeze(entire_stack(:,:,im_params.mem_ch,:,t));
    
    % invert the z-stack order
    raw_myosin = raw_myosin(:,:,end:-1:1);
    raw_membrane = raw_membrane(:,:,end:-1:1);
    
    if strcmpi(mem_params.mem_mask,'on')
        raw_myosin = make_mem_mask(raw_membrane, ...
            raw_myosin,im_params,mem_params);
    end
    
    % Find local thresholds
    local_thresholds = threshold_stack4manifold(raw_myosin, ...
        th_params,im_params);
    local_thresholds = local_thresholds(:,:,ones(1,im_params.Z));
    
    % Threshold myosin
    myosin_thresh = raw_myosin.*(raw_myosin > local_thresholds);
    if DEBUGGING
        figure,showsub(@imagesc,{max(raw_myosin,[],3)},'Raw myosin','colorbar,axis equal tight;',...
            @imagesc,{local_thresholds(:,:,1)},'Threhold','colorbar,axis equal tight',...
            @imagesc,{max(raw_myosin > local_thresholds,[],3)},'Mask','colorbar,axis equal tight',...
            @imagesc,{max(myosin_thresh,[],3)},'Thresholded myosin','colorbar,axis equal tight'...
            );
        keyboard;
    end
    
    % Generate manifold
    manifold = get_manifold(myosin_thresh,manifold_params,im_params);
    if DEBUGGING
        imagesc(manifold);
        keyboard
    end
    
    % Use manifold to get myosin/membrane signal
    [myosin_manifold,fraction_found_myo(t-io.t0+1)] = get_int_around_manifold(raw_myosin,manifold,extract_params,im_params);
    [membrane_manifold,fraction_found_mem(t-io.t0+1)] = get_int_around_manifold(raw_membrane,manifold,extract_params,im_params);

    myosinM(:,:,:,t-io.t0+1) = myosin_manifold;
    membraneM(:,:,:,t-io.t0+1) = membrane_manifold;
    if DEBUGGING
        figure,showsub(@imagesc,{myosin_manifold(:,:,1)},'Layer 1','colorbar,axis equal tight;',...
            @imagesc,{myosin_manifold(:,:,2)},'Layer 2','colorbar,axis equal tight',...
            @imagesc,{myosin_manifold(:,:,3)},'Layer 3','colorbar,axis equal tight'...
             );
        figure,showsub(@imagesc,{membrane_manifold(:,:,1)},'Layer 1','colorbar; axis equal tight;',...
            @imagesc,{membrane_manifold(:,:,2)},'Layer 2','colorbar,axis equal tight',...
            @imagesc,{membrane_manifold(:,:,3)},'Layer 3','colorbar,axis equal tight'...
            );
    end
end

%%

if io.write2file
    write_tiff_stack(myosinM,[io.write_path 'myosin_manifold_early.tif']);
    write_tiff_stack(membraneM,[io.write_path 'memenbrane_manifold_early.tif']);
end
