physical_distance = nan(num_cells);
for i = 1:num_cells
    for j = 1:num_cells
        physical_distance(i,j) = nanmean( sqrt( ...
            (centroids_x(38,i)-centroids_x(38,j)).^2 + ...
            (centroids_y(38,i)-centroids_y(38,j)).^2 ...
            ) );
    end
end
physical_distance(logical(eye(num_cells))) = NaN;
physical_distance = physical_distance*0.1806;

%% Neighbor-connection map

connection_map = adjacency_matrix(neighborID,1);

%% Correlation distance
mcorr_dist = pdist2( ...
    myosins_rate',myosins_rate',@(x,y) nan_pearsoncorr(x,y,0));
mcorr_dist(logical(eye(num_cells))) = NaN;
figure,pcolor(mcorr_dist),colorbar,axis equal tight;
% Get CDF for all pairs
bins = linspace(-1,1,15);
figure,plot_pdf(mcorr_dist(:),bins);

% Get only next-neighbor
mcorr_dist_neighbors = mcorr_dist.*connection_map;
figure,pcolor(mcorr_dist_neighbors);
figure,plot_pdf(mcorr_dist_neighbors(:),bins);

%% Area_correlation distance

acorr_dist = squareform(pdist(areas_sm(1:end,:)', ...
    @(x,y) nan_pearsoncorr(x,y)));
acorr_dist(logical(eye(num_cells))) = NaN;
figure,pcolor(acorr_dist),colorbar,axis equal tight
figure,hist(acorr_dist(:));
acorr_dist_neighbors = acorr_dist.*connection_map;
figure,pcolor(acorr_dist_neighbors)
figure,hist(acorr_dist_neighbors(:))

%%
threshold = 0:10:30;
% mean_proj = zeros(1,numel(threshold));

for i = 1:numel(threshold)
    if i == 1
        on_cells = double(physical_distance < threshold(i+1));
    elseif i == numel(threshold)
        on_cells = double(physical_distance > threshold(i));
    else
        on_cells = double(physical_distance < threshold(i+1) & ...
            physical_distance > threshold(i));
    end
    
    on_cells(on_cells == 0) = NaN;
    
    thresholded_acorr = ang_diff1.*on_cells;
    mean_proj(i,:) = nanmean(thresholded_acorr(:));
    
end

%%
index = 0;
for lag = -10:10
    index = index + 1;
    dist = pdist2(myosins_rate',myosins_rate',@(x,y) nan_pearsoncorr(x,y,lag));
    dist(logical(eye(num_cells))) = 0;
    dist_neighbor = dist.*connection_map;
    mmcorr{index} = dist;
    mmcorr_neighbor{index} = dist_neighbor;

    mean_mmcorr(index) = nanmean(dist(:));
    mean_mmcorr_neighbor(index) = nanmean(dist_neighbor(:));
    
    std_mmcorr(index) = nanstd(dist(:));
    std_mmcorr_neighbor(index) = nanstd(dist_neighbor(:));
    
end
