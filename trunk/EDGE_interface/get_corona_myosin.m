function corona_myosins = get_corona_myosin(myosins,neighborID)

[num_frames,num_cells] = size(myosins);

corona_myosins = nan(num_frames,num_cells);

for t = 1:num_frames
    for i = 1:num_cells
        if ~isnan(neighborID{1,i})
            corona_myosins(t,i) = sum(myosins(t,neighborID{1,i}));
        end
    end
end
