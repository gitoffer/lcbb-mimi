%%
% in = input_twist;
in = input;
%% Make movies of individual pulses

pulseID = 6;
pulse_frames = pulse(pulseID).frame;

h.vx = vertices_x(pulse_frames,:); h.vy = vertices_y(pulse_frames,:);
h.frames2load = master_time(pulse(pulseID).embryo).frame(pulse_frames);
h.sliceID = 4;
h.cellID = pulse(pulseID).cellID;
h.input = in(pulse(pulseID).embryo);
h.channels = {'Membranes','Myosin'};
h.measurement = pulse(pulseID).curve;
h.border = 'on';
% h.mtype = 'short';

F = make_cell_img(h);

% Save movie (to appropriate folder)
% if strcmpi(in(1).folder2load,input_twist(1).folder2load)
%     if IDs(cellID).which == 1, var_name = '006'; else var_name = '022'; end
%     movie2avi(F,['~/Desktop/EDGE processed/Twist ' var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% elseif strcmpi(in(1).folder2load,input(1).folder2load)
%     if IDs(cellID).which == 1, var_name = '4'; else var_name = '7'; end
%     movie2avi(F,['~/Desktop/EDGE processed/Embryo ' var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% end

%% Align all pulses
[time,aligned_peaks,aligned_myosin] = align_peaks(pulse,myosins_sm);
[~,~,aligned_area] = align_peaks(pulse,areas_sm);
[~,~,aligned_area_rate] = align_peaks(pulse,areas_rate);
[~,~,aligned_myosin_rate] = align_peaks(pulse,myosins_rate);

[sorted_sizes,sortedID] = sort([pulse.size],2,'descend');
cond = sortedID(1:100);
% cond = find([pulse.center] < 0);
% cond = find([pulse.size] > 4000 & [pulse.size] < 5000);

aligned_area_norm = bsxfun(@minus,aligned_area,nanmean(aligned_area,2));
% aligned_area_norm = bsxfun(@minus,aligned_area,aligned_area(:,22));

[aligned_area_norm,cols_left] = delete_nan_rows(aligned_area_norm,2);
aligned_myosin = aligned_myosin(:,cols_left);
aligned_area_rate = aligned_area_rate(:,cols_left);
aligned_myosin_rate = aligned_myosin_rate(:,cols_left);
time = time(:,cols_left);
% aligned_area_norm = bsxfun(@minus,aligned_area,aligned_area(:,19));
% aligned_area_norm = bsxfun(@rdivide,aligned_area_norm,nanmax(aligned_area_norm,[],2));

%% Correct for framerate differences

corrected_area_norm = ...
    resample_traces(aligned_area_norm,[pulse.embryo],[input.dt]);
corrected_myosin = ...
    resample_traces(aligned_myosin,[pulse.embryo],[input.dt]);
[corrected_area_rate,dt] = ...
    resample_traces(aligned_area_rate,[pulse.embryo],[input.dt]);


figure
% C = rand(numel(cond),3);

cells = [pulse(cond).cellID];
locs = [pulse(cond).center_frame];
embs = [pulse(cond).embryo];
clear labels

for i = 1:numel(cond)
    labels{i} = ['Embryo ' num2str(embs(i)) ...
        ', Cell ' num2str(cells(i)) ...
        ', Frame ' num2str(fix(locs(i)))];
end

showsub_vert(@plot,{[pulse(cond).aligned_time_padded],[pulse(cond).curve_padded]},'Detected pulses','xlabel(''Time (sec)'');ylabel(''Intensity (a.u.)'')',...
    @plot,{dt,corrected_myosin(cond,:)'},'Aligned pulses','xlabel(''Aligned time (sec)'')',...
    @plot,{dt,corrected_area_norm(cond,:)'},'Aligned areal response','xlabel(''Aligned time (sec)'')', ...
    3);

suptitle(['Weakest 20 peaks (out of ' num2str(num_peaks) ', ' num2str(num_embryos) ' embryos)'])
legend(labels)

%% Subplots of sorted pulses

figure;

subplot(1,7,1)
h = plot(num_peaks:-1:1,sorted_sizes);
set(h,'linewidth',5);
set(gca,'CameraUpVector',[1,0,0]);
set(gca,'Xlim',[1 numel(pulse)]);
set(gca,'Xtick',[]);
ylabel('pulse size');

subplot(1,7,2:3)
[X,Y] = meshgrid(dt,num_peaks:-1:1);
pcolor(X,Y,corrected_myosin(sortedID,:)),shading flat, axis tight
colorbar
title('Aligned pulses')
xlabel('Aligned time (sec)'); ylabel('PulseID');

% subplot(1,7,4:5)
% plot(num_peaks:-1:1,...
%     nanmean(corrected_area_norm(:,1:10),2)-nanmean(corrected_area_norm(:,11:21),2));
% set(gca,'Xlim',[1 numel(pulse)]);
% set(gca,'CameraUpVector',[1 0 0]);

subplot(1,7,4:5)
[X,Y] = meshgrid(dt,num_peaks:-1:1);
pcolor(X,Y,corrected_area_norm(sortedID,:)),shading flat, axis tight
colorbar
caxis([-20 20]),colorbar
title('Aligned areal responses')
xlabel('Aligned time (sec)'); ylabel('PulseID');

subplot(1,7,6:7)
[X,Y] = meshgrid(dt,num_peaks:-1:1);
pcolor(X,Y,corrected_area_rate(sortedID,:)),shading flat, axis tight
colorbar
caxis([-8 8]),colorbar
title('Aligned areal rate')
xlabel('Aligned time (sec)'); ylabel('PulseID');

%% Sort pulses according to individual embryo pulse sizes

sorted = sort_pulses(pulse);

x = dt;

top = sorted{1};
middle = sorted{2};
bottom = sorted{3};

figure
hold on

% Errorbar graphs for area_norm
errorbar(x,nanmean(corrected_area_norm([top.pulseID],:)),...
    nanstd(corrected_area_norm([top.pulseID],:)),'r-');
errorbar(x,nanmean(corrected_area_norm([middle.pulseID],:)),...
    nanstd(corrected_area_norm([middle.pulseID],:)),'k-');
errorbar(x,nanmean(corrected_area_norm([bottom.pulseID],:)),...
    nanstd(corrected_area_norm([bottom.pulseID],:)),'b-');

figure
hold on

% Errorbar graphs for myosin
errorbar(x,nanmean(corrected_myosin([top.pulseID],:)),...
    nanstd(corrected_myosin([top.pulseID],:)),'r-');
errorbar(x,nanmean(corrected_myosin([middle.pulseID],:)),...
    nanstd(corrected_myosin([middle.pulseID],:)),'k-');
errorbar(x,nanmean(corrected_myosin([bottom.pulseID],:)),...
    nanstd(corrected_myosin([bottom.pulseID],:)),'b-');

hist(nanmean(corrected_area_norm([bottom.pulseID],1:9),2) ...
    - nanmean(corrected_area_norm([bottom.pulseID],11:end),2))
h = findobj(gca,'Type','patch');
set(h,'FaceColor','red');
hold on
hist(gca,nanmean(corrected_area_norm([top.pulseID],1:9),2) ...
    - nanmean(corrected_area_norm([top.pulseID],11:end),2))

%% Arbitrarily selected time-pieces

random_areal = zeros(size(aligned_area_norm));
t0s = randi(num_frames,100,1);
tfs = min(t0s+numel(x),num_frames);

for i = 1:100
    t0 = t0s(i); tf = tfs(i);
    this_trace = nan(1,size(aligned_area_norm,2);
    this_trace(tf-t0+1,2) = areas_sm(t0:tf,randi(sum(num_cells)));
    random_areal(i,:) = this_trace;
end

%%

for cellID = 1:num_cells
    F = make_cell_img(vertices_x,vertices_y,1:60,4,cellID,in,{'Membranes','Myosin'});
    if isstruct(F)
        movie2avi(F,['~/Desktop/EDGE processed/Embryo 4/cell_movies/cell_' num2str(cellID) '_t1-60']);
    end
end

% %% Errorbars
% 
% cutoffs = prctile(sorted_sizes,[25 75]);
% 
% cond1 = sortedID(1:find(sorted_sizes < cutoffs(2),1));
% cond2 = sortedID(find(sorted_sizes < cutoffs(2),1)+1:find(sorted_sizes < cutoffs(1),1));
% cond3 = sortedID(find(sorted_sizes < cutoffs(1),1):end);
% % cond4 = sortedID(121:160);
% 
% figure
% x = (-10:10);
% plot(x,aligned_myosin(cond1,:)')
% 
% figure
% % errorbar(x,nanmean(aligned_area_norm(cond4,:)), ...
% %     nanstd(aligned_area_norm(cond4,:)),'g-')
% hold on
% errorbar(x,nanmean(aligned_area_norm(cond3,:)),...
%     nanstd(aligned_area_norm(cond3,:)),'b-');
% errorbar(x,nanmean(aligned_area_norm(cond2,:)),...
%     nanstd(aligned_area_norm(cond2,:)),'k-')
% errorbar(x,nanmean(aligned_area_norm(cond1,:)),...
%     nanstd(aligned_area_norm(cond1,:)),'r-')
% legend(['Top 151-200'],...
%     'Top 101-150','Top 51-100','Top 50');
% 
% figure
% % errorbar(x,nanmean(aligned_area_norm(cond4,:)), ...
% %     nanstd(aligned_area_norm(cond4,:)),'g-')
% hold on
% errorbar(x,nanmean(aligned_myosin(cond3,:)),...
%     nanstd(aligned_myosin(cond3,:)),'b-');
% errorbar(x,nanmean(aligned_myosin(cond2,:)),...
%     nanstd(aligned_myosin(cond2,:)),'k-')
% errorbar(x,nanmean(aligned_myosin(cond1,:)),...
%     nanstd(aligned_myosin(cond1,:)),'r-')
% legend(['Bottom 25 %-tile'],...
%     'Middle 50 %-tile','Top 25 %-tile');

