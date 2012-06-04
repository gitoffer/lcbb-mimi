% Area rate distance
% D_area = pdist(areas_rate',@nan_pearsoncorr);
% D_area = squareform(D_area);
% D_area(logical(eye(num_cells))) = NaN;

% D_myosins = pdist(myosins_rate',@nan_pearsoncorr);
% D_myosins = squareform(D_myosins);
% D_myosins(logical(eye(num_cells))) = NaN;

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

%% Correlation distance
% mcorr_dist = squareform(pdist(myosins_rate',@nan_pearsoncorr));
% mcorr_dist(logical(eye(num_cells))) = NaN;
% figure,pcolor(mcorr_dist),colorbar,axis equal tight
% mcorr_dist_neighbors = mcorr_dist.*connection_map;
% figure,hist(mcorr_dist_neighbors(:))

%% Neighbor-connection map

connection_map = nan(num_cells);

for i = 1:num_cells
    my_neighb = neighborID{1,i};
    if any(~isnan(my_neighb))
        connection_map(i,my_neighb) = 1;
    end
end
figure,pcolor(connection_map); axis equal tight

%% Area_correlation distance

acorr_dist = squareform(pdist(areas_sm(1:end,:)', ...
    @(x,y) nan_pearsoncorr(x,y,1)));
acorr_dist(logical(eye(num_cells))) = NaN;
figure,pcolor(acorr_dist),colorbar,axis equal tight
figure,hist(acorr_dist(:));
acorr_dist_neighbors = acorr_dist.*connection_map;
figure,pcolor(acorr_dist_neighbors)
figure,hist(acorr_dist_neighbors(:))

%%
threshold = 0:4:16;
mean_acorr = zeros(1,numel(threshold));

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
    
    thresholded_acorr = acorr_dist.*on_cells;
    mean_acorr(i) = nanmean(thresholded_acorr(:));
    
end





