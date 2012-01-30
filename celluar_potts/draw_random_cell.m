function cell = draw_random_cell(lattice)

[N,M] = size(lattice);

n = randi(N);
m = randi(M);

cell.i = n;
cell.j = m;