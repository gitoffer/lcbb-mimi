%EXTRACT DEPTH-MANIFOLD OF MYOSIN
%RETURN MEMBRANES,MYOSIN AND CADHERIN AT THAT DEPTH

%FOR EACH EMBRYO NEED TO DETERMINE CONVENIENT PARAMETERS!
% requieres embryo axis to lay horizontally (otherwise modify line ...)
% always control if manifold (indqf) is correct using 
% d=indqf-indq, (d=smoothened-discrete data) - Deviations should be 
% of order of fluctuations within a myosin blob

clear variables;
file='Embryo01_t21_z';
dir  = '/Volumes/LaCie - Lab/MICROSCOPY DATA/Leica/2009/070109 SquGFP Gap43attp2-wt/Embryo01/';
targ_dir = '/Volumes/LaCie - Lab/MICROSCOPY DATA/Leica/2009/070109 SquGFP Gap43attp2-wt/Embryo01/Projection/';

% E_PARAMS: embryo-parameters
e_params.lx = 20;
e_params.ly = 20;
e_params.threshold_perc = 5;
e_params.smoothing = 15;

% Imaging properties
im_params.Z = 7;
im_params.T = 100;
im_params.ext = 2*1024;
im_params.X = 1000;
im_params.Y = 400;
im_params.num_channels = 2;
im_params.myo_ch = 1;
im_params.mem_ch = 2;

% Processing parameters
pr_params.mem_mask = 1;
pr_params.mask_sigma_th = 1;
pr_params.write2file = 1;
pr_params.thickness = 2;

im0 = load_data4manifold(dir,file,im_params);
raw_myosin = im0{im_params.myo_ch};
raw_membrane = im0{im_params.mem_ch};

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

%not indicated to do because 5% signal becomes too little
%Membrane maks easily covers the myosin structures
%eventually try to apply membrane mask only to lower layers where
%cells are hardly constricted and membranes lay far away from blobs

%% get thresholded myosin stack (contains only local top %-age pixels)
%  supposed to yield good estimate of depth of intense myosin

myosin_threshed = threshold_img_stack(raw_myosin,


thresh_myo=get_stuff_threshold_fn(rawmyo,Lx,Ly,top,0);
figure(11); clf; imagesc(thresh_myo); colorbar;

Rmyo=zeros(xdim,ydim);
for n=1:nz %apply threshold to each level
    Rmyo=rawmyo(:,:,n); %array to calculate weighted average depth
    Rmyo(Rmyo<thresh_myo)=0;
    Tmyo(:,:,n)=Rmyo;
end
clear Rmyo;

%%  get depth of intense myosin - first discrete then smooth

%order myosin signal at (x,y) and get fractional content in each layer
[rmyo ind]=sort(Tmyo,3,'descend');
tmyo=sum(rmyo(:,:,:),3);
for n=1:nz 
    rmyo(:,:,n)=rmyo(:,:,n)./tmyo;
end
rmyo(isnan(rmyo))=0;

%make weighted average to get estimate of myosin depth at (x,y)
indq=zeros(xdim,ydim);
for i=1:xdim
    for j=1:ydim
        indq(i,j)=sum((rmyo(i,j,1:4).*ind(i,j,1:4)));
    end
end
figure(21); clf; imagesc(indq,[0,nz]); colorbar;
%%
%Remove strong deviations compared to 
%typical depth values in a-p direction, assuming no strong depth varyation in posterior anterior
%direction. Consider measurements within a dn thick slice in a-p direction
%indq=indq.*MembMask;       % remove membrane contribution from depth data
dn=16;                     % thickness of slice in A-P direction
for n=1:dn:ydim            % remove leftovers of membrane which typically deviate strongly from structure myosin
    A=indq(:,n:n+dn-1);    %use this line if AP-axis vertically
%    A=indq(n:n+dn-1,:);    %use this line if AP-axis horiz
    [r,c,v]=find(A);
    m=mean(v); s=std(v);
    A(A>(m+s))=0;          %this must be adjusted if embryo is tilted
   indq(:,n:n+dn-1)=A;    %change this line if AP-acis vertically
%    indq(n:n+dn-1,:)=A;    %use this line if ap axis horizontally
end
clear A;
figure(30); clf; imagesc(indq,[0,nz]); colorbar;

%make a smooth manifold out of discrete depth data
indn=indq*0;
indn(indq>0)=1;
[indqf,filt] = get_filtered_gauss(indq,ext,Smooth_depth,0);
[indnf,filt] = get_filtered_gauss(indn,ext,Smooth_depth,0);
indqf(indnf>0)=indqf(indnf>0)./indnf(indnf>0);
figure(40); clf; imagesc(indqf,[0,nz]); colorbar;
%with this procedure depth at (x,y) posititons of indqf show no systematic
%deviation from indq, pixelwise variations exist but are on the 
%order of intrinsic fluctuations within a single blob, mean deviation is 
%of order 10^-2;
%so far gave a great match!

break
%% GET Myosin Actin and Cadherin around MyosinDepth Manifold
clear threshmyo v rmyo indnf ind indn filt r
%read rawmyo again including the membrane
for j=1:nz
    jstr = int2str(j-1);
%     if (j < 11)
%         jstr=strcat('0',jstr);
%     end
    data_file=strcat(dir,file,jstr,'_ch00.tif');
    rawmyo(:,:,j) = imread(data_file);
end
%parameters of routine get_stuff_around_manifold:
%(data,depth_manifold, nz,+-n,interpolate);
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

