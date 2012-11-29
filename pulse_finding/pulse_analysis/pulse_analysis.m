%%
% in = input_twist;
in = input;

%% Make movies of individual pulses

F = make_pulse_movie(pulse(936),input,vertices_x,vertices_y,master_time);

% Save movie (to appropriate folder)
% if strcmpi(in(1).folder2load,input_twist(1).folder2load)
%     if IDs(cellID).which == 1, var_name = '006'; else var_name = '022'; end
%     movie2avi(F,['~/Desktop/EDGE processed/Twist ' var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% elseif strcmpi(in(1).folder2load,input(1).folder2load)
%     if IDs(cellID).which == 1, var_name = '4'; else var_name = '7'; end
%     movie2avi(F,['~/Desktop/EDGE processed/Embryo ' var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% end

%% Sub-set of pulses

subIDs = find([pulse.center] < -50);
% Resort
sub_pulse = pulse(subIDs);

pulseOI = pulse;
num_peaks = numel(pulseOI);

%% Align all pulses
[time,aligned_peaks,aligned_myosin] = align_peaks(pulseOI,myosins_sm);
[~,~,aligned_area] = align_peaks(pulseOI,areas_sm);
[~,~,aligned_area_rate] = align_peaks(pulseOI,areas_rate);
[~,~,aligned_myosin_rate] = align_peaks(pulseOI,myosins_rate);

% Sort pulses based on their magnitude
[sorted_sizes,sortedID] = sort([pulseOI.size],2,'descend');
% 
aligned_area_norm = bsxfun(@minus,aligned_area,nanmean(aligned_area,2));

cond = sortedID(1:10);

[aligned_area_norm,cols_left] = delete_nan_rows(aligned_area_norm,2);
aligned_myosin = aligned_myosin(:,cols_left);
aligned_area_rate = aligned_area_rate(:,cols_left);
aligned_myosin_rate = aligned_myosin_rate(:,cols_left);
time = time(:,cols_left);

% Correlate for framerate differences
corrected_area_norm = ...
    resample_traces(aligned_area_norm,[pulseOI.embryo],[input.dt]);
corrected_myosin = ...
    resample_traces(aligned_myosin,[pulseOI.embryo],[input.dt]);
[corrected_area_rate,dt] = ...
    resample_traces(aligned_area_rate,[pulseOI.embryo],[input.dt]);

%% Plot a subset of pulses

figure
% C = rand(numel(cond),3);
cells = [pulseOI(cond).cellID];
locs = [pulseOI(cond).center_frame];
embs = [pulseOI(cond).embryo];
clear labels

for i = 1:numel(cond)
    legend_labels{i} = ['Embryo ' num2str(embs(i)) ...
        ', Cell ' num2str(cells(i)) ...
        ', Frame ' num2str(fix(locs(i)))];
end

showsub_vert(@plot,{[pulseOI(cond).aligned_time_padded],[pulseOI(cond).curve_padded]},'Detected pulses','xlabel(''Time (sec)'');ylabel(''Intensity (a.u.)'')',...
    @plot,{dt,corrected_myosin(cond,:)'},'Aligned pulses','xlabel(''Aligned time (sec)'')',...
    @plot,{dt,corrected_area_norm(cond,:)'},'Aligned areal response','xlabel(''Aligned time (sec)'')', ...
    3);

suptitle(['Weakest 20 peaks (out of ' num2str(num_peaks) ', ' num2str(num_embryos) ' embryos)'])
legend(legend_labels)

%% Heatmap of sorted pulses

figure;

subplot(1,5,1)
h = plot(numel(pulseOI):-1:1,[pulseOI(sortedID).size]);
set(h,'linewidth',5);
set(gca,'CameraUpVector',[1,0,0]);
set(gca,'Xlim',[1 numel(pulseOI)]);
set(gca,'Xtick',[]);
ylabel('Pulse size');

subplot(1,5,2:3)
[X,Y] = meshgrid(dt,numel(pulseOI):-1:1);
pcolor(X,Y,corrected_myosin(sortedID,:)),shading flat, axis tight
colorbar
title('Aligned pulses')
xlabel('Aligned time (sec)'); ylabel('PulseID');

subplot(1,5,4:5)
sorted_area_norm = sort(corrected_area_norm,2,'descend');
area_diff = nan(1,num_peaks);
for i = 1:num_peaks
    area_diff(i) = nanmean(corrected_area_norm(i,1:7)) - nanmean(corrected_area_norm(i,end-6:end));
end
% area_diff = sorted_area_norm(:,2) - sorted_area_norm(:,last_nonan_idx-1);

% plot(num_peaks:-1:1,...
%     nanmean(corrected_area_norm(:,1:5),2)-nanmean(corrected_area_norm(:,end-4:end),2));
% set(gca,'Xlim',[1 numel(pulseOI)]);
% set(gca,'CameraUpVector',[1 0 0]);

subplot(1,5,4:5)
[X,Y] = meshgrid(dt,numel(pulseOI):-1:1);
pcolor(X,Y,corrected_area_norm(sortedID,:)),shading flat, axis tight
colorbar
caxis([-15 15]),colorbar
title('Aligned areal responses')
xlabel('Aligned time (sec)'); ylabel('PulseID');

% subplot(1,7,6:7)
% [X,Y] = meshgrid(dt,num_peaks:-1:1);
% pcolor(X,Y,corrected_area_rate(sortedID,:)),shading flat, axis tight
% colorbar
% caxis([-8 8]),colorbar
% title('Aligned areal rate')
% xlabel('Aligned time (sec)'); ylabel('PulseID');

%% Sort pulses according to individual embryo pulseOI sizes

binned = bin_pulses(pulseOI);

x = dt;

top = binned{1}; middle_top = binned{2}; middle_bottom = binned{3}; bottom = binned{4};
topIDs = [top.pulseID]; middle_topIDs = [middle_top.pulseID]; middle_bottomIDs = [middle_bottom.pulseID]; bottomIDs = [bottom.pulseID];
% for i = 1:numel(top)
%     topIDs(i) = find([top(i).pulseID] == subIDs);
% end
% for i = 1:numel(middle_top)
%     middle_topIDs(i) = find([middle_top(i).pulseID] == subIDs);
% end
% for i = 1:numel(middle_bottom)
%     middle_bottomIDs(i) = find([middle_bottom(i).pulseID] == subIDs);
% end
% for i = 1:numel(bottom)
%     bottomIDs(i) = find([bottom(i).pulseID] == subIDs);
% end

figure
hold on

% Errorbar graphs for area_norm
shadedErrorBar(x,nanmean(corrected_area_norm(topIDs,:)),...
    nanstd(corrected_area_norm(topIDs,:)),'r-',1);
shadedErrorBar(x,nanmean(corrected_area_norm(middle_topIDs,:)),...
    nanstd(corrected_area_norm(middle_topIDs,:)),'k-',1);
shadedErrorBar(x,nanmean(corrected_area_norm(middle_bottomIDs,:)),...
    nanstd(corrected_area_norm(middle_bottomIDs,:)),'b-',1);
shadedErrorBar(x,nanmean(corrected_area_norm(bottomIDs,:)),...
    nanstd(corrected_area_norm(bottomIDs,:)),'g-',1);

figure
hold on

% Errorbar graphs for myosin
shadedErrorBar(x,nanmean(corrected_myosin(topIDs,:)),...
    nanstd(corrected_myosin(topIDs,:)),'r-',1);
shadedErrorBar(x,nanmean(corrected_myosin(middle_topIDs,:)),...
    nanstd(corrected_myosin(middle_topIDs,:)),'k-',1);
shadedErrorBar(x,nanmean(corrected_myosin(middle_bottomIDs,:)),...
    nanstd(corrected_myosin(middle_bottomIDs,:)),'b-',1);
shadedErrorBar(x,nanmean(corrected_myosin(bottomIDs,:)),...
    nanstd(corrected_myosin(bottomIDs,:)),'g-',1);

figure
shadedErrorbar(x,nanmean(corrected_area_norm(topIDs,:)),...
    nanstd(corrected_area_norm(topIDs,:)),'r',1);
hold on
plot(x,corrected_area_norm);

%% 

hist(nanmean(corrected_area_norm([middle.pulseID],1:9),2) ...
    - nanmean(corrected_area_norm([middle.pulseID],11:end),2))
h = findobj(gca,'Type','patch');
set(h,'FaceColor','red');
set(h,'FaceAlpha',0.3);
hold on
hist(gca,nanmean(corrected_area_norm([bottom.pulseID],1:9),2) ...
    - nanmean(corrected_area_norm([bottom.pulseID],11:end),2))
h = findobj(gca,'Type','patch');
set(h(1),'FaceColor','green');
hist(gca,nanmean(corrected_area_norm([top.pulseID],1:9),2) ...
    - nanmean(corrected_area_norm([top.pulseID],11:end),2))
h = findobj(gca,'Type','patch');
% set(h(1),'FaceAlpha',0.3);
