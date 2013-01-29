function avg_vec = avg_stics_cells(stics_cells)

[num_cells,num_frames] = size(stics_cells);
avg_vec = cell(num_cells,1);

for i = 1:num_cells
    mean_x = [];
    mean_y = [];
    for j = 1:num_frames
        this_stics = stics_cells{i,j};
        this_stics(this_stics == 0) = NaN;
        if any(any(~isnan(this_stics)))
            mean_x = [mean_x nanmean(nanmean(this_stics(:,:,1)))];
            mean_y = [mean_y nanmean(nanmean(this_stics(:,:,2)))];
        end
    end
    avg_vec{i} = cat(2,mean_x,mean_y);
end
