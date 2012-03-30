tobe_measured = myosins_rate(1:end,:);
[num_frames,num_cells] = size(tobe_measured);
meas_name = 'constriction rate (later)';

[meas_n,cells_w_neighb] = neighbor_msmt(tobe_measured,neighborID(1,:));

%% Plot average dynamic correlation between focall cell and its neighbors
cellIDs = 1:82;

foo = zeros(num_cells,10,21);

for j = cellIDs
    for i = 1:10
        try
            foo(j,i,:) = nanxcorr(tobe_measured(:,j),meas_n{j}(:,i),10);
        catch err
            foo(j,i,:) = nan(1,21);
        end
    end
end

avg_foo = squeeze(nanmean(foo,2));
std_foo = squeeze(nanstd(foo,0,2));
[x,y] = meshgrid(-10:10,1:82);
pcolor(x,y,avg_foo),colorbar,axis equal tight;

%% Plot measurement for focal cell and its neighbors
focal_cell = 33;

figure
subplot(2,1,1),plot(tobe_measured(:,focal_cell),'k-')
title([meas_name ' for cell #' num2str(focal_cell)]);
[x,y] = meshgrid(1:num_frames,neighborID{1,focal_cell});
subplot(2,1,2),pcolor(x,y,meas_n{focal_cell}');
ylabel(['Cell #' num2str(focal_cell) ' neighbors']);
xlabel('Time (frames)');colorbar;

%% Plot dynamic correlation between focal cell and its neighbors
figure,

focal_cell = 48;
% plot focal and neighbor behavior
subplot(3,1,1),
plot(tobe_measured(:,focal_cell),'k-','LineWidth',5);
hold on;plot(meas_n{focal_cell});
names = cellstr(num2str(neighborID{1,focal_cell}));
legend('Focal cell', names{:});
title(['Cell' num2str(focal_cell) ' and neighbor ' meas_name])

% plot correlation
subplot(3,1,2),plot(-10:10,squeeze(foo(focal_cell,:,:))')
names = cellstr(num2str(neighborID{1,focal_cell}));
legend(names{:});
title(['Neighbor-to-focal cell cross-correlation in ' meas_name])

% plot avg correlation
% plot correlation
subplot(3,1,3)
errorbar(-10:10,avg_foo(focal_cell,:),std_foo(focal_cell,:))
title('Average cross-correlation')

%% Calculate or plot

% Get Pearson's correlation for neighboring cells
handle.vertex_x = vertices_x;
handle.vertex_y = vertices_y;
handle.savename = '~/Desktop/Neighbor behavior/pearsons_myosin_rate (all)/cell_';
pearsons_myosin = neighbor_cell_pearson(tobe_measured,meas_n,cells_w_neighb,neighborID,handle);

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
    movie2avi(F,['~/Desktop/Cell neighbors contraction rate/cell_' num2str(focal_cell)]);
end

%% Get neighbor angles

centroid_x_neighbor = neighbor_msmt(centroids_x,neighborID(1,:));
centroid_y_neighbor = neighbor_msmt(centroids_y,neighborID(1,:));



