%% Visualize_embryo_script
in = input;


%% Select the embryo
embryoID = 3;

%% Plot cells as patch objects

X = fits_all.make_binary_sequence(cells([cells.embryoID] == embryoID));

h.m = X;
h.vertex_x = embryo_stack(embryoID).vertex_x;
h.vertex_y = embryo_stack(embryoID).vertex_y;
h.todraw = 1:num_cells(embryoID);
h.input = in(embryoID);

h.title = '';

F = draw_measurement_on_cells_patch(h);
