tobe_measured = areas_rate(1:end,:);
[num_frames,num_cells] = size(tobe_measured);
meas_name = 'Contraction rate (late)';

[meas_n,cells_w_neighb] = neighbor_msmt(tobe_measured,neighborID(1,:));
num_foci = numel(cells_w_neighb);

%% Plot average dynamic correlation between focall cell and its neighbors

% Parameters
wt = 5;

%Preallocate memory
dynamic_corr = cell(1,num_foci);
avg_dynamic_corr = nan(num_cells,2*wt+1);
std_dynamic_corr = nan(num_cells,2*wt+1);
max_dynamic_corr = cell(1,num_foci);
shift_dynamic_corr = cell(1,num_foci);

% Loop through focus cells
for j = 1:numel(cells_w_neighb)
    cellID = cells_w_neighb(j);
    % get dynamic corr for all neighbors
    num_neighbors = numel(neighborID{1,cellID});
    this_corr = zeros(num_neighbors,2*wt+1);
%     keyboard
    for i = 1:num_neighbors
        this_corr(i,:) = nanxcorr(tobe_measured(:,cellID),meas_n{cellID}(:,i),wt);
    end
    dynamic_corr{j} = this_corr;
    avg_dynamic_corr(cellID,:) = nanmean(this_corr,1);
    std_dynamic_corr(cellID,:) = nanstd(this_corr,1);
    [m,I] = nanmax(abs(this_corr),[],2);
    max_dynamic_corr{j} = m';
    shift_dynamic_corr{j} = I'-wt;
end

[x,y] = meshgrid(-wt:wt,1:num_cells);
pcolor(x,y,avg_dynamic_corr),colorbar,axis equal tight;
title(['Dynamic correlation between neighbors for ' meas_name]);

%% Plot measurement for focal cell and its neighbors
focal_cell = 15;

figure
subplot(2,1,1),plot(tobe_measured(:,focal_cell),'k-')
title([meas_name ' for cell #' num2str(focal_cell)]);
[x,y] = meshgrid(1:num_frames,neighborID{1,focal_cell});
subplot(2,1,2),pcolor(x,y,meas_n{focal_cell}');
ylabel(['Cell #' num2str(focal_cell) ' neighbors']);
xlabel('Time (frames)');colorbar;

%% Plot dynamic correlation between focal cell and its neighbors
figure,

focal_cell = 15;
% plot focal and neighbor behavior
subplot(3,1,1),
plot(tobe_measured(:,focal_cell),'k-','LineWidth',5);
hold on;plot(meas_n{focal_cell});
names = cellstr(num2str(neighborID{1,focal_cell}));
legend('Focal cell', names{:});
title(['Cell' num2str(focal_cell) ' and neighbor ' meas_name])

% plot correlation
subplot(3,1,2),plot(-wt:wt,squeeze(dynamic_corr{find(cells_w_neighb == focal_cell)})')
names = cellstr(num2str(neighborID{1,focal_cell}));
legend(names{:});
title(['Neighbor-to-focal cell cross-correlation in ' meas_name])

% plot avg correlation
% plot correlation
subplot(3,1,3)
errorbar(-wt:wt,avg_dynamic_corr(focal_cell,:),std_dynamic_corr(focal_cell,:))
title('Average cross-correlation')

%% Calculate or plot

% Get Pearson's correlation for neighboring cells
handle.vertex_x = vertices_x;
handle.vertex_y = vertices_y;
handle.savename = '~/Desktop/Neighbor behavior/pearsons_contraction_rate (all)/cell_';
pearsons = neighbor_cell_pearson(tobe_measured,meas_n,cells_w_neighb,neighborID,handle);

%% Plot measurement on cells (for comparison to above)

% Get corrcoef
for j = 1:numel(cells_w_neighb)
    focal_cell = cells_w_neighb(j);
    neighbor_cells = neighborID{1,focal_cell};
    focal_cell_meas = tobe_measured(:,focal_cell);
    
    measurement2plot = meas_n{focal_cell};
    measurement2plot = cat(2,focal_cell_meas,measurement2plot);
    
    % Plot on cells
    handle.todraw = [focal_cell neighbor_cells'];
    handle.m = measurement2plot;
    handle.vertex_x = vertices_x;
    handle.vertex_y = vertices_y;
    handle.title = ['Contraction rates of cell #' num2str(focal_cell) ' and its neighbors'];
    F = draw_measurement_on_cell_small(handle);
    movie2avi(F,['~/Desktop/Neighbor behavior/contraction_rate (all)/cell_' num2str(focal_cell)]);
end

%% Get neighbor angles
num = 1:num_foci;

max_corr = cell2mat(shift_dynamic_corr(num));
tobe_plotted = max_corr(:);

centroid_x_neighbor = neighbor_msmt(centroids_x,neighborID(1,:));
centroid_y_neighbor = neighbor_msmt(centroids_y,neighborID(1,:));

angles = get_neighbor_angle(centroids_x,centroids_y, ...
    centroid_x_neighbor,centroid_y_neighbor,cells_w_neighb, ...
    unwrap(deg2rad(orientations)));

angles_mat = cell2mat(angles)';

%     hold on
%     polar(angles_mat(1,:)',abs(tobe_plotted),'r*');
%     hold off
%     drawnow; pause(1);

thresh = 0;

polar(angles_mat(tobe_plotted>thresh),tobe_plotted(tobe_plotted>thresh),'r*');
hold on;
polar(angles_mat(tobe_plotted<-thresh),-tobe_plotted(tobe_plotted<-thresh),'b*');
ylabel(meas_name)
hold off

