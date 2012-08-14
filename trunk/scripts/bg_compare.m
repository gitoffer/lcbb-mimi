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

significant_cr = zeros(num_frames,num_cells);
for j = 1:num_cells
    for i = 1:num_frames
        idx = findnearest(areas_rate(i,j), xi);
        if relative_sm(idx) > 2
            significant_cr(i,j) = areas_rate(i,j);
        end
    end
end

%%
areas = [];
mean_int = [];

for i = 1:num_cells
    stats{i} = regionprops(logical(significant_cr(1:15,i)), ...
        significant_cr(1:15,i),{'MeanIntensity','Area'});
    areas = [areas stats{i}.Area];
    number(i) = numel(stats{i});
    mean_int = [mean_int stats{i}.MeanIntensity];
end
