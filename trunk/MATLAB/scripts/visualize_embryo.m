%% Visualize_embryo_script
in = input;


%% Select the embryo
embryo = 7;

%% Plot cells as patch objects

h.m = cat(1,cell_fits([IDs.which] == embryo).cluster_labels)';

h.vertex_x = vertices_x(find(~isnan(master_time(embryo).frame)),find([IDs.which]==embryo));
h.vertex_y = vertices_y(find(~isnan(master_time(embryo).frame)),find([IDs.which]==embryo));
h.todraw = 1:num_cells(embryo);
h.input = in(embryo);

h.title = '';

F = draw_measurement_on_cells_patch(h);
