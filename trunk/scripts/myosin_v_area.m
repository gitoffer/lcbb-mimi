%Load data
folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements';
msmts2make = {'myosin','area','vertex-x','vertex-y','neighbors','ellipse'};

m = load_edge_data(folder2load,msmts2make{:});
areas = extract_msmt_data(m,'area','on');
myosins = extract_msmt_data(m,'myosin intensity','on');
neighborID = extract_msmt_data(m,'identity of neighbors','off');

[num_frames,num_z,num_cells] = size(areas);
%% Generate correlations
zslice = 2;

areas_sm = smooth2a(squeeze(areas(:,zslice,:)),1,0);
myosins_sm = smooth2a(squeeze(myosins(:,zslice,:)),1,0);

areas_rate = -central_diff_multi(areas_sm,1,1);
myosins_rate = central_diff_multi(myosins_sm);

wt = 7;
correlations = nanxcorr(myosins_rate,areas_rate,wt,1);
%% Scatter plots of myosin versus area
signal = myosins_sm;
signal2 = areas_sm;

Xext = 1000;
Yext = 400;
um_per_px = .19;

% Make all leading 0's NaN
for i = 1:num_cells
    foo = signal(:,i);
    I = find(foo>0,1);
    signal(1:I,i) = NaN;
    signal2(1:I,i) = NaN;
end

rate = central_diff_multi(signal,1,1);
rate2 = central_diff_multi(signal2,1,1);

% Plot scatter plots/2D histograms
scatter(signal(:),rate2(:)),xlabel('Myosin'),ylabel('Constriction rate')
figure,scatter(myosins_sm(:),rate2(:)),xlabel('Myosin rate'),ylabel('Constriction rate')
scatter(rate(:),rate2(:)),xlabel('Myosin rate'),ylabel('Constriction rate')

[histmat,xedges,yedges] = hist2(signal(:),rate2(:));
figure,pcolor(xedges,yedges,histmat'),colorbar;xlabel('Myosin'),ylabel('Constriction rate');

[histmat,xedges,yedges] = hist2(rate(:),rate2(:));
figure,pcolor(xedges,yedges,histmat'),colorbar;xlabel('Myosin rate'),ylabel('Constriction rate');

[histmat,xedges,yedges] = hist2(signal(:),signal2(:));
figure,pcolor(xedges,yedges,histmat'),colorbar;xlabel('Myosin'),ylabel('Area');

%% Finds consecutive runs of increasing myosin; segments the myosin data
% using hysteresis thresholding

counts = find_consecutive_logical(myosins_rate > 0);
count_threshold = 3; %Threshold how many consecutive runs you want
% Segment out the section of increasing myosin that has at least
% the given number of inreasing runs
roi = hysteresis_thresholding(counts,1,count_threshold,[1;1;1]);

input = myosins_rate; input(~roi) = NaN;
response = areas_rate; response(~roi) = NaN;
imagesc(areas_rate'),caxis([-5 5]),colorbar,xlabel('Time'),ylabel('Cells');
title('Smoothed constriction rate');
figure,imagesc(response'),xlabel('Time'),ylabel('Cells'),caxis([-5 5]),colorbar;
title('Constriction rates masked by myosin increasing regions');

%% Plot PDF distributinos
nbins = 30;
overall_mean = nanmean(areas_rate(:));
overall_std = nanstd(areas_rate(:));
edges = linspace(nanmin(areas_rate(:)),nanmax(areas_rate(:)),20);

filtered_mean = nanmean(response(:));
filtered_std = nanstd(response(:));

plot_pdf(cat(2,areas_rate(:),response(:)),nbins);
% hold on,plot_pdf(response(:),edges,'FaceAlpha',.5);
% xlabel('Rate (\mum^2/s(');ylabel('Probability density');
legend('Overall measured constriction rate','Constriction rates masked by myosin increasing frames'),hold off;

%% Make movies
resp_m = draw_measurement_on_cells(m,response,1000,400,.19);

increasing = nan(size(response));
increasing(response > 0) = response(response > 0);
decreasing = nan(size(response));
decreasing(response < 0) = response(response < 0);

inc_m = draw_measurement_on_cells(m,increasing,Xext,Yext,um_per_px);
dec_m = draw_measurement_on_cells(m,decreasing,Xext,Yext,um_per_px);

%%
close all
tracks = load_edge_data(folder2load,'centroid-x','centroid-y');
centroids.x = extract_msmt_data(tracks,'centroid-x','on');
centroids.y = extract_msmt_data(tracks,'centroid-y','on');

cent_x = squeeze(centroids.x(:,zslice,:));
cent_y = squeeze(centroids.y(:,zslice,:));

nbins = 40;
bins = linspace(1,70,nbins);
all_counts = zeros(num_frames,nbins);
for i = 1:num_frames
    D = pdist(cat(2,cent_x(i,:)',cent_y(i,:)'));
    all_counts(i,:) = histc(D,bins);
end

figure,pcolor(bins,1:num_frames,all_counts),colorbar;
title('Spatial distribution of all cells');
xlabel('Distance between cells (\mum)'),ylabel('Time (s)')

mask = double(logical(roi)); mask(mask == 0) = NaN;
cent_x = squeeze(centroids.x(:,zslice,:)).*mask;
cent_y = squeeze(centroids.y(:,zslice,:)).*mask;
masked_counts = zeros(num_frames,nbins);
for i = 1:num_frames
    D = pdist(cat(2,cent_x(i,:)',cent_y(i,:)'));
    masked_counts(i,:) = histc(D,bins);
end

figure,pcolor(bins,1:num_frames,masked_counts),colorbar;
title('Spatial distribution of increasing myosin cells');
xlabel('Distance between cells (\mum)'),ylabel('Time (s)')

inc_mask = response>0;
inc_mask = double(inc_mask);
inc_mask(inc_mask == 0) = NaN;
cent_x = squeeze(centroids.x(:,zslice,:)).*inc_mask;
cent_y = squeeze(centroids.y(:,zslice,:)).*inc_mask;
inc_counts = zeros(num_frames,nbins);
for i = 1:num_frames
    D = pdist(cat(2,cent_x(i,:)',cent_y(i,:)'));
    inc_counts(i,:) = histc(D,bins);
end

figure,pcolor(bins,1:num_frames,inc_counts),colorbar;
title('Spatial distribution of increasing CR cells');
xlabel('Distance between cells (\mum)'),ylabel('Time (s)')

dec_mask = response<0;
dec_mask = double(dec_mask);
dec_mask(dec_mask == 0) = NaN;
cent_x = squeeze(centroids.x(:,zslice,:)).*dec_mask;
cent_y = squeeze(centroids.y(:,zslice,:)).*dec_mask;
dec_counts = zeros(num_frames,nbins);
for i = 1:num_frames
    D = pdist(cat(2,cent_x(i,:)',cent_y(i,:)'));
    dec_counts(i,:) = histc(D,bins);
end

figure,pcolor(bins,1:num_frames,dec_counts),colorbar;
title('Spatial distribution of decreasing cells');
xlabel('Distance between cells (\mum)'),ylabel('Time (s)')






