function neighbor = draw_random_neighbor(cell)

cell_n = cell.i;
cell_m = cell.j;
j = randi(8);

switch j
    case 1
        neighbor_i = cell_n - 1;
        neighbor_j = cell_m - 1;
    case 2
        neighbor_i = cell_n - 1;
        neighbor_j = cell_m;
    case 3
        neighbor_i = cell_n - 1;
        neighbor_j = cell_m + 1;
    case 4
        neighbor_i = cell_n;
        neighbor_j = cell_m - 1;
    case 5
        neighbor_i = cell_n;
        neighbor_j = cell_m + 1;
    case 6
        neighbor_i = cell_n + 1;
        neighbor_j = cell_m - 1;
    case 7
        neighbor_i = cell_n + 1;
        neighbor_j = cell_m;
    case 8
        neighbor_i = cell_n + 1;
        neighbor_j = cell_m + 1;
end

neighbor.i = neighbor_i;
neighbor.j = neighbor_j;