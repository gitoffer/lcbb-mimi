
%% Finds consecutive runs of increasing myosin; segments the myosin data
% using hysteresis thresholding

counts = find_consecutive_logical(myosins_rate > 0);
count_threshold = 5; %Threshold how many consecutive runs you want
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
% resp_m = draw_measurement_on_cells(m,response,1000,400,.19);
Xext = 1000; Yext = 400; um_per_px = .19;

increasing = nan(size(response));
increasing(response > 0) = response(response > 0);
decreasing = nan(size(response));
decreasing(response < 0) = response(response < 0);

masks = nan(size(response));
masks(response > 0) = 1;
masks(response < 0) = -1;

% inc_m = draw_measurement_on_cells(m,masks,Xext,Yext,um_per_px);
% inc_m = draw_measurement_on_cells(m,increasing,Xext,Yext,um_per_px);
% dec_m = draw_measurement_on_cells(m,decreasing,Xext,Yext,um_per_px);

handle.todraw = 1:num_cells;
handle.m = decreasing;
handle.title = 'Decreasing constriction rates';
handle.vertex_x = vertices_x;
handle.vertex_y = vertices_y;
handle.caxis = [-3 3];
F = draw_measurement_on_cell_small(handle);
movie2avi(F,['~/Desktop/cr_myosins_5_dec_m'])

% handle.m = increasing;
% F = draw_measurement_on_cell_small(handle);
% movie2avi(F,['~/Desktop/cr_filtered_incmyo_' num2str(thresh)])

%%
% close all
% tracks = load_edge_data(folder2load,'centroid-x','centroid-y');
% centroids.x = extract_msmt_data(tracks,'centroid-x','on');
% centroids.y = extract_msmt_data(tracks,'centroid-y','on');

cent_x = centroids_x;
cent_y = centroids_y;

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






