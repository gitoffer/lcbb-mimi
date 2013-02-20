pulseOI = pulses;

%% plot a subset of pulses

figure

% Select a subset of pulses to display
subset = sortedID(1:10);

cellOI = [pulses(subset).cellID];
locs = [pulses(subset).center];
embs = [pulses(subset).embryoID];

for i = 1:numel(subset)
    legend_labels{i} = ['embryo ' num2str(embs(i)) ...
        ', cell ' num2str(cellOI(i)) ...
        ', time ' num2str(fix(locs(i)))];
end

showsub_vert( ...
    @plot,{cat(1,pulses(subset).aligned_time_padded)',cat(1,pulses(subset).fit_padded)'}, ...
    'detected pulses','xlabel(''time (sec)'');ylabel(''intensity (a.u.)'')',...
    @plot,{pulses(1).corrected_time,corrected_myosin(subset,:)'},'aligned pulses','xlabel(''aligned time (sec)'')',...
    @plot,{pulses(1).corrected_time,corrected_area_norm(subset,:)'},'aligned areal response','xlabel(''aligned time (sec)'')', ...
    3);

suptitle(['Strongest 10 peaks (out of ' num2str(num_peaks) ', ' num2str(num_embryos) ' embryos)'])
legend(legend_labels)

%% heatmap of sorted pulses

figure;

subplot(1,5,1)
h = plot(numel(pulseOI):-1:1,[pulses(sortedID).amplitude]);
set(h,'linewidth',5);
set(gca,'cameraupvector',[1,0,0]);
set(gca,'xlim',[1 numel(pulseOI)]);
set(gca,'xtick',[]);
ylabel('pulses size');

subplot(1,5,2:3)
[x,y] = meshgrid(pulses(1).corrected_time,numel(pulseOI):-1:1);
pcolor(x,y,corrected_myosin(sortedID,:)),shading flat, axis tight
colorbar;
title('aligned pulses')
xlabel('aligned time (sec)'); ylabel('pulseID');

subplot(1,5,4:5)
% sorted_area_norm = sort(corrected_area_norm,2,'descend');
% plot(num_peaks:-1:1,...
%     nanmean(corrected_area_norm(:,1:5),2)-nanmean(corrected_area_norm(:,end-4:end),2));
% set(gca,'xlim',[1 numel(pulseOI)]);
% set(gca,'cameraupvector',[1 0 0]);

subplot(1,5,4:5)
[x,y] = meshgrid(pulses(1).corrected_time,numel(pulseOI):-1:1);
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

%% Sort pulses according to individual embryo pulseOI sizes

binned = bin_pulses(pulseOI);

x = pulses(1).corrected_time;

top = binned{1}; middle_top = binned{2}; middle_bottom = binned{3}; bottom = binned{4};
topids = [top.pulseID]; middle_topids = [middle_top.pulseID]; middle_bottomids = [middle_bottom.pulseID]; bottomids = [bottom.pulseID];
% for i = 1:numel(top)
%     topids(i) = find([top(i).pulseID] == subIDs);
% end
% for i = 1:numel(middle_top)
%     middle_topids(i) = find([middle_top(i).pulseID] == subIDs);
% end
% for i = 1:numel(middle_bottom)
%     middle_bottomids(i) = find([middle_bottom(i).pulseID] == subIDs);
% end
% for i = 1:numel(bottom)
%     bottomids(i) = find([bottom(i).pulseID] == subIDs);
% end

figure
hold on

% errorbar graphs for area_norm
shadederrorbar(x,nanmean(corrected_area_norm(topids,:)),...
    nanstd(corrected_area_norm(topids,:)),'r-',1);
shadederrorbar(x,nanmean(corrected_area_norm(middle_topids,:)),...
    nanstd(corrected_area_norm(middle_topids,:)),'k-',1);
shadederrorbar(x,nanmean(corrected_area_norm(middle_bottomids,:)),...
    nanstd(corrected_area_norm(middle_bottomids,:)),'b-',1);
shadederrorbar(x,nanmean(corrected_area_norm(bottomids,:)),...
    nanstd(corrected_area_norm(bottomids,:)),'g-',1);

figure
hold on

% errorbar graphs for myosin
shadederrorbar(x,nanmean(corrected_myosin(topids,:)),...
    nanstd(corrected_myosin(topids,:)),'r-',1);
shadederrorbar(x,nanmean(corrected_myosin(middle_topids,:)),...
    nanstd(corrected_myosin(middle_topids,:)),'k-',1);
shadederrorbar(x,nanmean(corrected_myosin(middle_bottomids,:)),...
    nanstd(corrected_myosin(middle_bottomids,:)),'b-',1);
shadederrorbar(x,nanmean(corrected_myosin(bottomids,:)),...
    nanstd(corrected_myosin(bottomids,:)),'g-',1);

figure
shadederrorbar(x,nanmean(corrected_area_norm(topids,:)),...
    nanstd(corrected_area_norm(topids,:)),'r',1);
hold on
plot(x,corrected_area_norm);
