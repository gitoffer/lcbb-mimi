%% Visualize_embryo_script
in = input;


%% Select the embryo
embryoID = 5;

%% Plot cells as patch objects

X = zeros(130,embryo_stack(embryoID).num_cell);
X1 = cluster1.make_binary_sequence(cells([cells.embryoID] == embryoID));
X2 = cluster2.make_binary_sequence(cells([cells.embryoID] == embryoID));
X3 = cluster3.make_binary_sequence(cells([cells.embryoID] == embryoID));
X4 = cluster4.make_binary_sequence(cells([cells.embryoID] == embryoID));
X5 = cluster5.make_binary_sequence(cells([cells.embryoID] == embryoID));
X(logical(X1)) = 1;
X(logical(X2)) = 2;
X(logical(X3)) = 3;
X(logical(X4)) = 4;
X(logical(X5)) = 5;

% h.m = c8(:,ones(1,embryo_stack(embryoID).num_frame))';
h.m = X(1:embryo_stack(embryoID).num_frame,:);
h.vertex_x = embryo_stack(embryoID).vertex_x;
h.vertex_y = embryo_stack(embryoID).vertex_y;
h.todraw = 1:num_cells(embryoID);
h.input = in(embryoID);

h.title = '';

F = draw_measurement_on_cells_patch(h);
