areas = [];
mean_int = [];

for i = 1:num_cells
    stats{i} = regionprops(logical(peaks(1:15,i)), ...
        areas_rate(1:15,i),{'MeanIntensity','Area','Image'});
    areas = [areas stats{i}.Area];
    mean_int = [mean_int stats{i}.MeanIntensity];
end

%%
clear pulsing_cells_early;
j=0;
for i = 1:num_cells
    foo = peak_locations(1:15,i);
    if ~isempty(foo(~isnan(foo)))
        j = j+1;
        pulsing_cells_early(j) = i;
    end
end

%%
figure

cellID = 126;

showsub_vert( ...
    @plotyy,{t0+1:t0+max_frame,myosins_rate(t0+1:t0+max_frame,cellID),t0+1:t0+max_frame,peaks(1:max_frame,cellID)},['Myosin rates in cell ' num2str(cellID)],'xlabel(''Time'');legend(''Smoothed rate'',''Fitted peaks'')',...
    @plotyy,{t0+1:t0+max_frame,areas_sm(t0+1:t0+max_frame,cellID),t0+1:t0+max_frame,significant_cr(t0+1:t0+max_frame,cellID)},'Apical area','legend(''Apical area'',''Significant area changes'')' ...
    )
% saveas(gcf,[handle.io.save_dir '/peak_gauss/cells/early_pulses_cell_' num2str(cellID)],'fig');

%%
[aligned_peaks,aligned_myosin] = align_peaks(individual_peaks,peak_locations,peak_cells,myosins_sm);
[aligned_peaks,aligned_area] = align_peaks(individual_peaks,peak_locations,peak_cells,areas_sm);

cond = peak_sizes > 800;

figure
showsub_vert(@plot,{aligned_peaks(cond,:)'},'Myosin pulse','',@plot,{aligned_area(cond,:)'},'Area','',@plot,{aligned_myosin(cond,:)'},'Myosin intensity','')
% suptitle('Peak size > 800')

cells = peak_cells(cond);
locs = peak_centers(cond);
clear labels
for i = 1:numel(cells)
    labels{i} = ['Cell ' num2str(cells(i)) ' time ' num2str(fix(locs(i)))];
end
legend(labels)

%%

cond1 = peak_sizes > 800;
cond2 = peak_sizes > 500 & peak_sizes < 800;
cond3 = peak_sizes > 300 & peak_sizes < 500;
cond4 = peak_sizes > 0 & peak_sizes < 300;

aligned_area_norm = bsxfun(@rdivide,aligned_area,nanmean(aligned_area,2));

figure
errorbar(-21:21,nanmean(aligned_area_norm(cond1,:)),nanstd(aligned_area_norm(cond1,:)),'r-');
hold on
errorbar(-21:21,nanmean(aligned_area_norm(cond2,:)),nanstd(aligned_area_norm(cond2,:)),'b-');
errorbar(-21:21,nanmean(aligned_area_norm(cond3,:)),nanstd(aligned_area_norm(cond3,:)),'g-');
errorbar(-21:21,nanmean(aligned_area_norm(cond4,:)),nanstd(aligned_area_norm(cond4,:)),'k-');



