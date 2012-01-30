function deltaE = differential_adhesion(lattice,cell,neighbor,p)

homophilic = p.energy_parameters(1);
heterophilic = p.energy_parameters(2);
sigma = p.energy_parameters(3);

i = cell.i;
j = cell.j;

n = neighbor.i;
m = neighbor.j;

identity = p.identity;

cell_number = lattice(i,j);
neighbor_number = lattice(n,m);

cell_id = identity(cell_number);
neighbor_id = identity(neighbor_number);

area_cell = numel(lattice(lattice == cell_number));
area_neighbor = numel(lattice(lattice == neighbor_number));

perimeters = reion_props(lattice,'Perimeter');
perimeter_cell = perimeters(cell_number).Perimeter;
perimeter_neighbor = perimeters(neighbor_number).Perimeter;



deltaE = homophilic + ...