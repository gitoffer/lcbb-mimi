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

cellID = 2;

showsub_vert( ...
    @plotyy,{1:30,myosins_rate(1:30,cellID),1:30,peaks(1:30,cellID)},['Myosin rates in cell ' num2str(cellID)],'xlabel(''Time'');legend(''Smoothed rate'',''Fitted peaks'')',...
    @plotyy,{1:30,areas_sm(1:30,cellID),1:30,significant_cr(1:30,cellID)},'Apical area','legend(''Apical area'',''Significant area changes'')' ...
    )
saveas(gcf,[handle.io.save_dir '/peak_gauss/cells/early_pulses_cell_' num2str(cellID)],'fig');
