function neighbor = draw_random_neighbor(lattice,cell)

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

% Now check for border cells
[N,M] = size(lattice);
if neighbor_i > N
				neighbor_i = 1;
elseif neighbor_i < 1
				neighbor_i = N;
end
if neighbor_j > m
				neighbor_j = 1;
elseif neighbor_j < 1
				neighbor_j = M;
end

neighbor.i = neighbor_i;
neighbor.j = neighbor_j;
