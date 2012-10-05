%%

figure

cellID = randi(num_cells(2)) + num_cells(1);

showsub_vert( ...
    @plotyy,{t*input(c(i)).dt,myosins_rate(:,cellID).*(myosins_rate(:,cellID) > 0),...
    t*input(c(i)).dt,cell_fits(:,cellID)},...
    ['Myosin rates in cell ' num2str(cellID)],'xlabel(''Time'');legend(''Smoothed rate'',''Fitted peaks'')',...
    @plotyy,{t*input(c(i)).dt,areas_sm(:,cellID),...
    t*input(c(i)).dt,significant_cr(:,cellID)},...
    'Apical area','legend(''Apical area'',''Significant area changes'')', ...
    2)

% saveas(gcf,[handle.io.save_dir '/peak_gauss/cells/early_pulses_cell_' num2str(cellID)],'fig');

%% Make movies of individual pulses

pulseID = 16;

figure;

F = make_cell_img(vertices_x,vertices_y,...
    pulse(pulseID).frame+input(c(pulse(pulseID).cellID)).lag,...
    4,pulse(pulseID).cellID,input(c(pulse(pulseID).cellID)),...
    {'Membranes','Myosin'},pulse(pulseID).curve);

%%

[time,aligned_peaks,aligned_myosin] = align_peaks(pulse,myosins_sm);
[~,~,aligned_area] = align_peaks(pulse,areas_sm);
[~,~,aligned_area_rate] = align_peaks(pulse,areas_rate);

[sorted_sizes,sortedID] = sort([pulse.size],2,'descend');
cond = sortedID(1:20);
% cond = find([pulse.center] < 0);
% cond = find([pulse.size] > 4000 & [pulse.size] < 5000);

aligned_area_norm = bsxfun(@minus,aligned_area,nanmean(aligned_area,2));
[aligned_area_norm,cols_left] = delete_nan_rows(aligned_area_norm,2);
aligned_myosin = aligned_myosin(:,cols_left);
aligned_area = aligned_area(:,cols_left);
time = time(:,cols_left);
% aligned_area_norm = bsxfun(@minus,aligned_area,aligned_area(:,19));
% aligned_area_norm = bsxfun(@rdivide,aligned_area_norm,nanmax(aligned_area_norm,[],2));

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
    @plot,{time(cond,:)',aligned_myosin(cond,:)'},'Aligned pulses','xlabel(''Aligned time (sec)'')',...
    @plot,{time(cond,:)',aligned_area_norm(cond,:)'},'Aligned areal response','xlabel(''Aligned time (sec)'')', ...
    3);

suptitle(['Weakest 20 peaks (out of ' num2str(num_peaks) ', ' num2str(num_embryos) ' embryos)'])
legend(labels)

%%

figure;

subplot(1,3,1)
h = plot(num_peaks:-1:1,[pulse(sortedID).size]);
set(h,'linewidth',5);
set(gca,'CameraUpVector',[1,0,0]);
set(gca,'Xtick',[]);
set(gca,'Box','off');

subplot(1,3,2:3)
[X,Y] = meshgrid(-10:10,num_peaks:-1:1);
pcolor(X,Y,aligned_area_norm(sortedID,:)),shading flat, axis tight

%%

cond1 = sortedID(1:20);
cond2 = sortedID(21:40);
cond3 = sortedID(41:end);
% cond4 = sortedID(121:160);

figure
x = (-10:10);
plot(x,aligned_area_norm(cond1,:)')

figure
% errorbar(x,nanmean(aligned_area_norm(cond4,:)), ...
%     nanstd(aligned_area_norm(cond4,:)),'g-')
hold on
errorbar(x,nanmean(aligned_area_norm(cond3,:)),...
    nanstd(aligned_area_norm(cond3,:)),'b-');
errorbar(x,nanmean(aligned_area_norm(cond2,:)),...
    nanstd(aligned_area_norm(cond2,:)),'k-')
errorbar(x,nanmean(aligned_area_norm(cond1,:)),...
    nanstd(aligned_area_norm(cond1,:)),'r-')
legend(['Top 151-200'],...
    'Top 101-150','Top 51-100','Top 50');

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
    F = make_cell_img(vertices_x,vertices_y,1:60,4,cellID,input,{'Membranes','Myosin'});
    if isstruct(F)
        movie2avi(F,['~/Desktop/EDGE processed/Embryo 4/cell_movies/cell_' num2str(cellID) '_t1-60']);
    end
end

