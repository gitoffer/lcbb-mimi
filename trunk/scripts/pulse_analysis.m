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

%%

[time,aligned_peaks,aligned_myosin] = align_peaks(pulse,myosins_sm);
[~,~,aligned_area] = align_peaks(pulse,areas_sm);
[~,~,aligned_area_rate] = align_peaks(pulse,areas_rate);

[sorted_sizes,sortedID] = sort([pulse.size],2,'descend');
cond = sortedID(1:10);

aligned_area_norm = bsxfun(@minus,aligned_area,nanmean(aligned_area,2));
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

showsub_vert(@plot,{[pulse(cond).aligned_time_padded],[pulse(cond).curve_padded]},'Peaks in rate','',...
    @plot,{time(cond,:)',aligned_area_norm(cond,:)'},'Area','', ...
    @plot,{time(cond,:)',aligned_myosin(cond,:)'},'Myosin intensity','xlabel(''Aligned frames (not corrected for frame rate)'')',...
    3);

suptitle(['Top 5 peaks (out of ' num2str(num_peaks) ')'])
legend(labels)

%%

cond1 = sortedID(1:30);
cond2 = sortedID(31:60);
cond3 = sortedID(61:90);
cond4 = sortedID(91:150);

figure
x = (-18:18)*8;
plot(x,aligned_area_norm(cond1,:)')

figure
errorbar(x,nanmean(aligned_area_norm(cond4,:)), ...
    nanstd(aligned_area_norm(cond4,:)),'g-')
hold on
errorbar(x,nanmean(aligned_area_norm(cond3,:)),...
    nanstd(aligned_area_norm(cond3,:)),'b-')
errorbar(x,nanmean(aligned_area_norm(cond2,:)),...
    nanstd(aligned_area_norm(cond2,:)),'k-')
errorbar(x,nanmean(aligned_area_norm(cond1,:)),...
    nanstd(aligned_area_norm(cond1,:)),'r-')
legend(['Top 151-200'],...
    'Top 101-150','Top 51-100','Top 50');

%%

for cellID = 1:num_cells
    F = make_cell_img(vertices_x,vertices_y,1:60,4,cellID,input,{'Membranes','Myosin'});
    if isstruct(F)
        movie2avi(F,['~/Desktop/EDGE processed/Embryo 4/cell_movies/cell_' num2str(cellID) '_t1-60']);
    end
end

