function cc = connected_clusters(roi,neighborID)

[num_frames,num_cells] = size(roi);
cc = nan(num_frames,num_cells);

for i = 1:num_cells
    for t = 1:num_frames
        neighbors = neighborID{t,i};
        if any(~isnan(neighbors))
            neighbors = roi(t,neighbors);
            cc(t,i) = numel(neighbors(neighbors > 0));
        end
    end
end

end