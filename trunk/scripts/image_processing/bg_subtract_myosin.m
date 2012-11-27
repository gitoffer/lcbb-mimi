%BG_SUBTRACT_MYOSIN script to remove background level of myosin

% Path to the raw myosin stack (TIF)
path = '~/Desktop/Mimi/Data/11-10-2012/cta SqhGFP GapCherry/3/myosin_stack.tif';
num_frames = 165;
num_slices = 9;

%% Load images

raw_myo = imread_multi(path,1,num_slices,num_frames);
raw_myo = permute(raw_myo,[1 2 4 5 3]);

% New image dimensions: X,Y,Z,T

%% Crop images

reference_z = 4;
reference_t = 1;

end_z = 7;
end_t = 20;

[~,bg_box] = imcrop(raw_myo(:,:,reference_z,reference_t),[]);
x0 = round(bg_box(1)); y0 = round(bg_box(2));
xf = round(x0+bg_box(3)); yf = round(y0+bg_box(4));

figure(301)
showsublink( ...
    @imshow,{imcrop(raw_myo(:,:,reference_z,reference_t),bg_box),[]},'Top z beginning t','', ...
    @imshow,{imcrop(raw_myo(:,:,end_z,end_t),bg_box),[]},'Top z beginning t','' ...
);

%% Calculate distribution of BG values and determine threshold
bg = raw_myo(y0:yf,x0:xf,reference_z:end_z,reference_t:end_t);

figure(302)
showsub( ...
    @hist,{flat(bg)},'Histogram of pixel values','',...
    @cdfplot,{flat(bg)},'CDF of pixel values', ''...
    );

% imsequence_play(bg);

threshold = mean(flat(bg)) + 3*std(flat(bg));

%% Get and display thresholded myosin image

display_time = 100;

myosin_max = max(raw_myo(:,:,1:4,:),[],3);
myosin_max = permute(myosin_max,[1 2 4 3]);

myosin_th = myosin_max.*(myosin_max > threshold);

figure(303)
showsub_vertlink( ...
    @imshow,{myosin_max(:,:,display_time),[]},'Max projected myosin','', ...
    @imshow,{myosin_th(:,:,display_time),[]},'Thresholded myosin','' ...
    )

% imsequence_play(myosin_th);

%% Write to a TIF stack

output_path = '~/Desktop/Mimi/Data/11-10-2012/cta SqhGFP GapCherry/3/myosin_th_1_4_3sigma.TIF';

write_tiff_stack(myosin_th,output_path);

