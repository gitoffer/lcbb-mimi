% In the process of restructuring manifold code. Do not use. - xies Jan 2012

%EXTRACT DEPTH-MANIFOLD OF MYOSIN
%RETURN MEMBRANES,MYOSIN AND CADHERIN AT THAT DEPTH

%FOR EACH EMBRYO NEED TO DETERMINE CONVENIENT PARAMETERS!
% requieres embryo axis to lay horizontally (otherwise modify line ...)
% always control if manifold (indqf) is correct using 
% d=indqf-indq, (d=smoothened-discrete data) - Deviations should be 
% of order of fluctuations within a myosin blob

clear variables, clc, close all
% Image filename, with extension but no directory path
io.file='';
% Directory path for image
io.path  = '';
% Directory path for target output images
io.write_path = '';
% Strings for writing/reading TIFF sequences
io.tstr = '_t';
io.zstr = '_z';
io.cstr = '_ch';
% First image in sequence to read
io.t0 = 1;
% Last image in sequence to read
io.tf = 100;

%% Embryo-specific processing parameters (these need to be tweaked every time)
th_params.wx = 20;
th_params.ly = 20;
th_params.perc = 5; % Top percentile to threshold myosin
th_params.bit_depth = 2^12 - 1; % Bit-depth of pixels, e.g. 2^12
th_params.filter_size = 20; % Gaussian size for smoothing the thresholded myosin

% Smoothing filter size for blurring the discrete Z-index
manifold_params.smoothing = 15;
manifold_params.avg_slice = 4;
manifold_params.display = 'on'; % See the manifold?

% Image properties
im_params.X = 1000; % Image size
im_params.Y = 400;
im_params.Z = 7; % Total Z-slices
im_params.T = 100; % Total frames
im_params.num_channels = 2; % Number of channels
im_params.myo_ch = 1;
im_params.mem_ch = 2;

% Processing parameters - mostly low-level
pr_params.mem_mask = 0; % Turn on/off membrake masking
pr_params.mask_sigma_th = 1;
pr_params.support = 2*im_params.X*im_params.Y; % Kernel support size for Gaussian filters
pr_params.write2file = 1;
pr_params.depth_sm = 2;
pr_params.high_pass = ;
pr_params.low_pass = ;

%%%%%%%%%% FUNCTIONALIZE!!!

for i = io.t0: io.tf
	input_data = load_stack4manifold(
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%

input_data = load_stack4manifold(dir,file,im_params);
raw_myosin = input_data{1};
raw_membrane = input_data{2};

%% make a membrane mask
if pr_params.mem_mask
    
    mem_mask = sum(raw_membrane(:,:,5:Z),3);
    mem_mask(mem_mask <= mean(mem_mask(:)) + ...
        pr_params.mask_sigma_th*std(mem_mask(:))) = 0;
    mem_mask(mem_mask ~= 0) = 1;
    
    mem_mask = bwmorph(mem_mask,'thick',e_params.thickness);
    mem_mask = ~mem_mask;
    figure(10);clf;imagesc(mem_mask);
    
    raw_myosin = raw_myosin.*mem_mask(:,:,ones(1,Z));
    
end

%not indiicated to do because 5% signal becomes too little
%Membrane maks easily covers the myosin structures
%eventually try to apply membrane mask only to lower layers where
%cells are hardly constricted and membranes lay far away from blobs

%% Perform local thresholding on myosin volume according to percentile cutoff.
% This makes estimaing intense myosin locations easier.
% Uses parameters:	pr_params.wx - local thresholding window size
%			pr_params.wy
%			pr_params.perc - top percentile to take

local_thresholds = threshold_img_stack( ...
	raw_myosin,th_params,'on','on'); % THIS NEEDS WORKING ON
% Will not be necessary after display is implemented in THRESHOLD_IMG_STACK
% figure(11); clf; imagesc(thresh_myo); colorbar;
% propagate thresholds throughout z-stack
local_thresholds = local_thresholds(:,:,ones(1,im_params.Z));

myosin_thresh = raw_myosin.*(raw_myosin > local_thresholds);

% Sort myosin-intensity along z and return the ranked index.
[myosin_sorted, intensity_index] = sort(myosin_thresh,5,'descend');
% Project in Z total myosin intensity.
myosin_thresh = sum(myosin_sorted,3);
% Divide sorted myosin by total intensity... This yields relative contribution fro each slice
myosin_sorted = myosin_sorted./myosin_tresh(:,:,ones(1,imparams.Z));
mysoin_sorted(isnan(myosin_sorted)) = 0;

% Get weighted-average...?
index = sum(myosin_sorted(:,:,1:4).*intensity_index(:,:,1:4));
figure(21); clf; imagesc(index,[0,nz]);colorbar;

%% Remove outliers in z-depth, testing against average z-depth values in AP axis.
% Assumption: There should be no strong 'uneven-ness' in AP axis.
%if pr_params.mem_mask
%	index_weighted = myosin_index.*mem_mask;
%end
%%
%Remove strong deviations compared to 
%typical depth values in a-p direction, assuming no strong depth varyation in posterior anterior
%direction. Consider measurements within a dn thick slice in a-p direction
%indq=indq.*MembMask;       % remove membrane contribution from depth data
%dn=16;                     % thickness of slice in A-P direction
%for n=1:dn:ydim            % remove leftovers of membrane which typically deviate strongly from structure myosin
%    A=indq(:,n:n+dn-1);    %use this line if AP-axis vertically
%    A=indq(n:n+dn-1,:);    %use this line if AP-axis horiz
%    [r,c,v]=find(A);
%    m=mean(v); s=std(v);
%    A(A>(m+s))=0;          %this must be adjusted if embryo is tilted
%   indq(:,n:n+dn-1)=A;    %change this line if AP-acis vertically
%    indq(n:n+dn-1,:)=A;    %use this line if ap axis horizontally
%end
%clear A;
%figure(30); clf; imagesc(indq,[0,nz]); colorbar;

%% Making the smooth manifold

% NOTE: COMMENT THIS SECTION REALLY WELL!
% Make a 'mask' of where the myosin is
myosin_mask = double(index > 0);
% Smooth/blur the index (which is discrete) by a Gaussian filter
[index_sm] = gaussian_filter(index,pr_params.support,pr_params.depth_sm,'off','off');
% Smooth/blur the mask by the same kernel
[myosin_mask_sm] = gaussian_filter(myosin_mask,pr_params.support,pr_params.depth_sm,'off','off');
% Divide the smoothed index by the mask, to 'normalize' the index
index_sm(index_sm > 0) = index_sm(myosin_mask > 0)./myosin_sm(myosin_sm > 0);
manifold =index_sm;
figure(40); clf; imagesc(manifold,[0,Z]); colorbar;

clear myosin_mask myosin_thresh myosin_sorted intensity_index myosin_mask_sm

myosin_manifold = get_int_around_manifold(raw_myosin,manifold,Z,5,'on');
membrane_mnifold = get_int_around_manifold(raw_mem,manifold,'on');

if pr_params.write2file
	
		
end

%%%%%%%%%%%%

%% GET Myosin Actin and Cadherin around MyosinDepth Manifold

rawcad=smooth3(rawcad);
Mmyo=get_stuff_around_manifold_fn(rawmyo,indqf,nz,5,1);
Cmyo=get_stuff_around_manifold_fn(rawcad,indqf,nz,5,1);
Amyo=get_stuff_around_manifold_fn(rawact,indqf,nz,5,1);

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

