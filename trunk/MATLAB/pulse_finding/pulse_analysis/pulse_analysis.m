%%
% in = input_twist;
in = input;

%% Make movies of individual pulses

F = make_pulse_movie(sub_pulse(541),input,vertices_x,vertices_y,master_time);

% save movie (to appropriate folder)
% if strcmpi(in(1).folder2load,input_twist(1).folder2load)
%     if ids(cellID).which == 1, var_name = '006'; else var_name = '022'; end
%     movie2avi(f,['~/desktop/edge processed/twist ' var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% elseif strcmpi(in(1).folder2load,input(1).folder2load)
%     if ids(cellID).which == 1, var_name = '4'; else var_name = '7'; end
%     movie2avi(f,['~/desktop/edge processed/embryo ' var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% end

%% sub-set of pulses

% subIDs = intersect(find(1:numel(pulse) < wt_cutoff),filtIDs);
% sub_pulse = subID_pulses(pulse,subIDs);

pulseOI = pulse;
num_peaks = numel(pulseOI);

%% Align all pulses

[time,aligned_peaks,aligned_myosin] = align_peaks(pulseOI,myosins_sm,opt);
[~,~,aligned_area] = align_peaks(pulseOI,areas_sm,opt);
[~,~,aligned_area_rate] = align_peaks(pulseOI,areas_rate,opt);
[~,~,aligned_myosin_rate] = align_peaks(pulseOI,myosins_rate,opt);

% sort pulses based on their magnitude
[sorted_sizes,sortedID] = sort([pulseOI.size],2,'descend');

% Mean-center pulse responses
aligned_area_norm = bsxfun(@minus,aligned_area,nanmean(aligned_area,2));

% Select a subset of pulses to display
cond = sortedID(1:10);

[aligned_area_norm,cols_left] = delete_nan_rows(aligned_area_norm,2);
aligned_myosin = aligned_myosin(:,cols_left);
aligned_area_rate = aligned_area_rate(:,cols_left);
aligned_myosin_rate = aligned_myosin_rate(:,cols_left);
aligned_area = aligned_area(:,cols_left);
time = time(:,cols_left);

% correlate for framerate differences
corrected_area = ...
    resample_traces(aligned_area,[pulseOI.embryo],[input.dt],opt);
corrected_area_norm = ...
    resample_traces(aligned_area_norm,[pulseOI.embryo],[input.dt],opt);
corrected_myosin = ...
    resample_traces(aligned_myosin,[pulseOI.embryo],[input.dt],opt);
[corrected_area_rate,corrected_time] = ...
    resample_traces(aligned_area_rate,[pulseOI.embryo],[input.dt],opt);

%%

corrected_area = interp_mat(corrected_area);
corrected_area_norm = interp_mat(corrected_area_norm);
corrected_area_rate = interp_mat(corrected_area_rate);
corrected_myosin = interp_mat(corrected_myosin);

%% plot a subset of pulses

figure
% c = rand(numel(cond),3);
cells = [pulseOI(cond).cellID];
locs = [pulseOI(cond).center_frame];
embs = [pulseOI(cond).embryo];

for i = 1:numel(cond)
    legend_labels{i} = ['embryo ' num2str(embs(i)) ...
        ', cell ' num2str(cells(i)) ...
        ', frame ' num2str(fix(locs(i)))];
end

showsub_vert(@plot,{[pulseOI(cond).aligned_time_padded],[pulseOI(cond).curve_padded]},'detected pulses','xlabel(''time (sec)'');ylabel(''intensity (a.u.)'')',...
    @plot,{corrected_time,corrected_myosin(cond,:)'},'aligned pulses','xlabel(''aligned time (sec)'')',...
    @plot,{corrected_time,corrected_area_norm(cond,:)'},'aligned areal response','xlabel(''aligned time (sec)'')', ...
    3);

suptitle(['weakest 20 peaks (out of ' num2str(num_peaks) ', ' num2str(num_embryos) ' embryos)'])
legend(legend_labels)

%% heatmap of sorted pulses

figure;

subplot(1,5,1)
h = plot(numel(pulseOI):-1:1,[pulseOI(sortedID).size]);
set(h,'linewidth',5);
set(gca,'cameraupvector',[1,0,0]);
set(gca,'xlim',[1 numel(pulseOI)]);
set(gca,'xtick',[]);
ylabel('pulse size');

subplot(1,5,2:3)
[x,y] = meshgrid(corrected_time,numel(pulseOI):-1:1);
pcolor(x,y,corrected_myosin(sortedID,:)),shading flat, axis tight
colorbar;
title('aligned pulses')
xlabel('aligned time (sec)'); ylabel('pulseID');

subplot(1,5,4:5)
% sorted_area_norm = sort(corrected_area_norm,2,'descend');
% area_diff = nan(1,num_peaks);
for i = 1:num_peaks
    area_diff(i) = nanmean(corrected_area_norm(i,1:7)) - nanmean(corrected_area_norm(i,end-6:end));
end
% area_diff = sorted_area_norm(:,2) - sorted_area_norm(:,last_nonan_idx-1);

% plot(num_peaks:-1:1,...
%     nanmean(corrected_area_norm(:,1:5),2)-nanmean(corrected_area_norm(:,end-4:end),2));
% set(gca,'xlim',[1 numel(pulseOI)]);
% set(gca,'cameraupvector',[1 0 0]);

subplot(1,5,4:5)
[x,y] = meshgrid(corrected_time,numel(pulseOI):-1:1);
pcolor(x,y,corrected_area_norm(sortedID,:)),shading flat, axis tight
colorbar
caxis([-15 15]),colorbar
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

x = corrected_time;

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
