%% Generate "physical distance" between cells

ref_time = 100;

physical_distance = nan(sum(num_cells));
for i = 1:sum(num_cells)
    for j = 1:sum(num_cells)
        physical_distance(i,j) = nanmean( sqrt(...
            (centroids_x(ref_time,i) - centroids_x(ref_time,j))^2 + ...
            (centroids_y(ref_time,i) - centroids_y(ref_time,j))^2));
    end
end

physical_distance = delete_off_embryo_interaction(physical_distance,IDs);

%% Generate the adjacency matrix

adj = adjacency_matrix(neighborID(:,[IDs.which] == 6),1);
% angles = rad_flip_quadrant(get_neighbor_angle(centroids_x,centroids_y,1));
% horizontal_adj = adj; horizontal_adj(abs(angles) > pi/6) = NaN;
% vertical_adj = adj; vertical_adj(abs(angles) < pi/6) = NaN;

%% Myosin correlation distance

Dm = squareform(pdist( ...
    myosin(1:end,1:sum(num_cells(1:5)))',@(x,y) nan_pearsoncorr(x,y,4)));

%% Dm - lower triangular matrix; mcorr_dist - lower triangular matrix without
% neighbor_map terms
neighbor_map = adj;

% Delete diagonals (self-interaction terms)
Dm(logical(eye(sum(num_cells(1:5))))) = NaN;
% Find only paris defined by "neighbor_map"
mcorr_dist_neighbors = Dm.*neighbor_map;
% mcorr_dist_vneighbors = Dm.*vertical_adj;
% mcorr_dist_hneighbors = Dm.*horizontal_adj;
mcorr_dist_neighbors(logical(triu( ones(474) ))) = NaN;
% mcorr_dist_hneighbors(logical(triu(ones(sum(num_cells))))) = NaN;
% mcorr_dist_vneighbors(logical(triu(ones(sum(num_cells))))) = NaN;

% Delete upper triangle
Dm(logical(tril(ones( 474 )))) = NaN;
% Delete neighbor-pairs
mcorr_dist = Dm;
mcorr_dist(~isnan(neighbor_map)) = NaN;
% Delete off-embryo blocks
mcorr_dist = delete_off_embryo_interaction(mcorr_dist,IDs(1:474));

%%
% Get CDF for all pairs
bins = linspace(-1,1,30);
figure,h = plot_cdf(mcorr_dist(:),bins);
set(h,'color','red');
hold on,h = plot_cdf(mcorr_dist_neighbors(:),bins);
set(h,'color','green');
% hold on,h = plot_cdf(mcorr_dist_hneighbors(:),bins);
% set(h,'color','k');
% hold on,plot_cdf(mcorr_dist_vneighbors(:),bins);
legend('Non-neighbor pairs','All neighbor pairs','Horizontal neighbors','Vertical neighbors');
hold off

%%
% Temporarily convert NaN to 0 to make addition work
mcorr_dist0 = mcorr_dist; mcorr_dist0(isnan(mcorr_dist)) = 0;
mcorr_dist_neighbors0 = mcorr_dist_neighbors;
mcorr_dist_neighbors0(isnan(mcorr_dist_neighbors)) = 0;
% Convert 0 back into NaN
myosin_correlations_matrix = mcorr_dist0 + mcorr_dist_neighbors0;
myosin_correlations_matrix(myosin_correlations_matrix==0) = NaN;
figure,h = pcolor(myosin_correlations_matrix),colorbar,axis equal tight;shading flat;
set(gca,'Xtick',[0 sum(num_cells)']);
xlabel('Cells');ylabel('Cells');

%% Area_correlation distance

acorr_dist = squareform(pdist(areas_rate(1:50,:)', ...
    @(x,y) nan_pearsoncorr(x,y)));
acorr_dist(logical(eye(sum(num_cells)))) = NaN;
acorr_dist(logical(triu(ones(sum(num_cells))))) = NaN;
figure,pcolor(acorr_dist),colorbar,axis equal tight,shading flat
figure,hist(acorr_dist(:));
acorr_dist_neighbors = acorr_dist.*adj;
figure,pcolor(acorr_dist_neighbors),shading flat
figure,hist(acorr_dist_neighbors(:))
