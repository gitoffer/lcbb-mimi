function corona_area = get_corona_area(areas,neighborID)

[num_frames,num_cells] = size(areas);

corona_area = nan(num_frames,num_cells);

for t = 1:num_frames
    for i = 1:num_cells
        if ~isnan(neighborID{1,i})
            corona_area(t,i) = sum(areas(t,neighborID{1,i}));
        end
    end
end
