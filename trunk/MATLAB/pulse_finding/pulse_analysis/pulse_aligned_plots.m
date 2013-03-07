fitsOI = fits;

%% plot a subset of fits

figure

% Select a subset of fits to display
subset = sortedID(1:10);

cellOI = [fits(subset).cellID];
locs = [fits(subset).center];
embs = [fits(subset).embryoID];

for i = 1:numel(subset)
    legend_labels{i} = ['embryo ' num2str(embs(i)) ...
        ', cell ' num2str(cellOI(i)) ...
        ', time ' num2str(fix(locs(i)))];
end

showsub_vert( ...
    @plot,{cat(1,fits(subset).aligned_time_padded)',cat(1,fits(subset).fit_padded)'}, ...
    'detected fits','xlabel(''time (sec)'');ylabel(''intensity (a.u.)'')',...
    @plot,{fits(1).corrected_time,corrected_myosin(subset,:)'},'aligned fits','xlabel(''aligned time (sec)'')',...
    @plot,{fits(1).corrected_time,corrected_area_norm(subset,:)'},'aligned areal response','xlabel(''aligned time (sec)'')', ...
    3);

suptitle(['Strongest 10 peaks (out of ' num2str(num_peaks) ', ' num2str(num_embryos) ' embryos)'])
legend(legend_labels)

%% heatmap of sorted fits

figure;

subplot(1,5,1)
h = plot(numel(fitsOI):-1:1,[fits(sortedID).amplitude]);
set(h,'linewidth',5);
set(gca,'cameraupvector',[1,0,0]);
set(gca,'xlim',[1 numel(fitsOI)]);
set(gca,'xtick',[]);
ylabel('fits size');

subplot(1,5,2:3)
[x,y] = meshgrid(fits(1).corrected_time,numel(fitsOI):-1:1);
pcolor(x,y,corrected_myosin(sortedID,:)),shading flat, axis tight
colorbar;
title('aligned fits')
xlabel('aligned time (sec)'); ylabel('pulseID');

subplot(1,5,4:5)
% sorted_area_norm = sort(corrected_area_norm,2,'descend');
% plot(num_peaks:-1:1,...
%     nanmean(corrected_area_norm(:,1:5),2)-nanmean(corrected_area_norm(:,end-4:end),2));
% set(gca,'xlim',[1 numel(fitsOI)]);
% set(gca,'cameraupvector',[1 0 0]);

subplot(1,5,4:5)
[x,y] = meshgrid(fits(1).corrected_time,numel(fitsOI):-1:1);
pcolor(x,y,corrected_area_norm(sortedID,:)),shading flat, axis tight
colorbar
caxis([-10 10]),colorbar
title('aligned areal responses')
xlabel('aligned time (sec)'); ylabel('pulseID');

% subplot(1,7,6:7)
% [x,y] = meshgrid(dt,num_peaks:-1:1);
% pcolor(x,y,corrected_area_rate(sortedID,:)),shading flat, axis tight
% colorbar
% caxis([-8 8]),colorbar
% title('aligned areal rate')
% xlabel('aligned time (sec)'); ylabel('pulseID');

%% Sort fits according to individual embryo fitsOI sizes

fits = fits.bin_fits;

fits.plot_binned_fits;

