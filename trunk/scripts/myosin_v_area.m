signal = myosins_sm;
signal2 = areas_sm;
for i = 1:num_cells
    foo = signal(:,i);
    I = find(foo>0,1);
    signal(1:I,i) = NaN;
    signal2(1:I,i) = NaN;
end

rate = central_diff_multi(signal,1,1);
rate2 = central_diff_multi(signal2,1,1);

scatter(signal(:),rate2(:)),xlabel('Myosin'),ylabel('Constriction rate')
figure,scatter(myosins_sm(:),rate2(:)),xlabel('Myosin rate'),ylabel('Constriction rate')
scatter(rate(:),rate2(:)),xlabel('Myosin rate'),ylabel('Constriction rate')

xedges = linspace(0,max(signal(:)),50);
yedges = linspace(min(rate2(:)),max(rate2(:)),50);
histmat = hist2(signal(:),rate2(:),xedges,yedges);
pcolor(xedges,yedges,histmat'),colorbar;xlabel('Myosin'),ylabel('Constriction rate');

xedges = linspace(min(rate(:)),max(rate(:)),50);
yedges = linspace(min(rate2(:)),max(rate2(:)),50);
histmat = hist2(rate(:),rate2(:),xedges,yedges);
figure,pcolor(xedges,yedges,histmat'),colorbar;xlabel('Myosin rate'),ylabel('Constriction rate');

xedges = linspace(min(signal(:)),max(rate(:)),50);
yedges = linspace(min(signal2(:)),max(signal2(:)),50);
histmat = hist2(signal(:),signal2(:),xedges,yedges);
figure,pcolor(xedges,yedges,histmat'),colorbar;xlabel('Myosin'),ylabel('Area');

%%

counts = find_consecutive_logical(myosins_rate > 0);
count_threshold = 5;
tic
roi = hysteresis_thresholding(counts,1,count_threshold,[1;1;1]);
toc

response = areas_rate;
response(~roi) = NaN;
imagesc(areas_rate'),caxis([-5 5]),colorbar,xlabel('Time'),ylabel('Cells')
title('Smoothed constriction rate');
figure,imagesc(response'),xlabel('Time'),ylabel('Cells'),caxis([-5 5]),colorbar
title('Constriction rates masked by myosin increasing regions');

% plot(response(:,40))

overall_mean = nanmean(areas_rate(:));
overall_std = nanstd(areas_rate(:));

filtered_mean = nanmean(response(:));
filtered_std = nanstd(response(:));

movie = draw_measurement_on_cells(m,response,1000,400,.19);

increasing = nan(size(response));
increasing(response > 0) = response(response > 0);
decreasing = nan(size(response));
decreasing(response < 0) = response(response < 0);

inc_m = draw_measurement_on_cells(m,increasing,1000,400,.19);
dec_m = draw_measurement_on_cells(m,decreasing,1000,400,.19);
