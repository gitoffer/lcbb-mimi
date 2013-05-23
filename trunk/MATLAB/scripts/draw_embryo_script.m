embryoID = 4;

h.vertex_y = embryo_stack(embryoID).vertex_y;
h.vertex_x = embryo_stack(embryoID).vertex_x;
h.title = 'Tracked cells';
h.todraw = 1:embryo_stack(embryoID).num_cell;
h.m = [cells([cells.embryoID] == embryoID).flag_tracked];
h.m = h.m(ones(1,embryo_stack(embryoID).num_frame),:);

F = draw_measurement_on_cells_patch(h);
