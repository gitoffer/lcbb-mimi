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

adj = adjacency_matrix(neighborID,find(time_mat==0,1));
angles = rad_flip_quadrant(get_neighbor_angle(centroids_x,centroids_y,1));
horizontal_adj = adj; horizontal_adj(abs(angles) > pi/6) = NaN;
vertical_adj = adj; vertical_adj(abs(angles) < pi/6) = NaN;

%% Myosin correlation distance
mcorr_dist = pdist2( ...
    myosins_rate(1:50,:)',myosins_rate(1:50,:)',@(x,y) nan_pearsoncorr(x,y,0));


% Delete diagonals
mcorr_dist(logical(eye(sum(num_cells)))) = NaN;
% Find only local ones
mcorr_dist_neighbors = mcorr_dist.*adj;
mcorr_dist_neighbors(logical(triu(ones(sum(num_cells))))) = NaN;
% Delete neighbor-pairs
mcorr_dist(~isnan(adj)) = NaN;
% Delete upper triangle
mcorr_dist(logical(tril(ones(sum(num_cells))))) = NaN;
% Delete off-embryo blocks
for i = 1:num_embryos
    mcorr_dist(c==i,c~=i) = NaN;
end
% Get CDF for all pairs
bins = linspace(-1,1,15);
figure,h = plot_pdf(mcorr_dist(:),bins);
set(h,'facecolor','red');
hold on,plot_pdf(mcorr_dist_neighbors(:),bins);
hold off

mcorr_dist0 = mcorr_dist; mcorr_dist0(isnan(mcorr_dist)) = 0;
mcorr_dist_neighbors0 = mcorr_dist_neighbors; mcorr_dist_neighbors0(isnan(mcorr_dist_neighbors)) = 0;

myosin_correlations_matrix = mcorr_dist0 + mcorr_dist_neighbors0;
myosin_correlations_matrix(myosin_correlations_matrix==0) = NaN;
figure,h = pcolor(myosin_correlations_matrix),colorbar,axis equal tight;shading flat;
set(gca,'Xtick',[0 cumsum(num_cells)']);
xlabel('Cells');ylabel('Cells');

%% Area_correlation distance

acorr_dist = squareform(pdist(areas_rate(1:50,:)', ...
    @(x,y) nan_pearsoncorr(x,y)));
acorr_dist(logical(eye(num_cells))) = NaN;
acorr_dist(logical(triu(ones(num_cells)))) = NaN;
figure,pcolor(acorr_dist),colorbar,axis equal tight,shading flat
figure,hist(acorr_dist(:));
acorr_dist_neighbors = acorr_dist.*adj;
figure,pcolor(acorr_dist_neighbors),shading flat
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
    dist = pdist2(areas_rate(1:50,:)',areas_rate(1:50,:)',@(x,y) nan_pearsoncorr(x,y,lag));
    dist(logical(eye(num_cells))) = 0;
    dist_neighbor = dist.*adj;
    aacorr{index} = dist;
    aacorr_neighbor{index} = dist_neighbor;

    mean_aacorr(index) = nanmean(dist(:));
    mean_aacorr_neighbor(index) = nanmean(dist_neighbor(:));
    
    std_aacorr(index) = nanstd(dist(:));
    std_aacorr_neighbor(index) = nanstd(dist_neighbor(:));
end


