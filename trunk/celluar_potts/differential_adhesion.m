function deltaE = differential_adhesion(lattice,p,cell,neighbor)
%DIFFERENTIAL_ADHESION
%
% SYNOPSIS: totalE = differential_adhesion(lattice, params);
%					  deltaE = differential_adhesion(lattice, params, cell_i, cell_j)
%
% xies@mit.edu. 20.415 Spring 2012.

switch nargin
				case 2
				% If there are only 2 inputs, calculate the total energy for the lattice given.
				
case 4
% If there are 4 inputs, then cell i and cell j are given, then we only calculate the change in energy if the identity of cell i was to be replaced by that of cell j.

homophilic = p.energy_parameters(1);
heterophilic = p.energy_parameters(2);
sigma = p.energy_parameters(3);

i = cell.i;
j = cell.j;

n = neighbor.i;
m = neighbor.j;

cell_number = lattice(i,j);
neighbor_number = lattice(n,m);

% Find the identity of the cells
cell_id = p.identity(cell_number);
neighbor_id = p.identity(neighbor_number);

% calculate cell area (pixel number)
area_cell = numel(lattice(lattice == cell_number));
area_neighbor = numel(lattice(lattice == neighbor_number));

% Need perimeter?
%perimeters = reion_props(lattice,'Perimeter');
%perimeter_cell = perimeters(cell_number).Perimeter;
%perimeter_neighbor = perimeters(neighbor_number).Perimeter;

% Thicken the cell areas by 1, and where the thickened cells overlap
% is defined to be the contact boundary (called junction)
bound_cell = bwmorph(lattice == cell_number,'thicken',1)
bound_neighbor = bwmorph(lattice == neighbor_number,'thicken',1);
junction_bf = numel(bound_cell_thick & bound_neighbor_thick);

% Now perform swap and calculate readjusted geometry
candidate_lattice = lattice;
candidate_lattice(i,j) = neighbor_id;

% Recalculate junction length
bound_cell = bwmorph(lattice == cell_number,'thicken',1)
bound_neighbor = bwmorph(lattice == neighbor_number,'thicken',1);
junction_after = numel(bound_cell_thick & bound_neighbor_thick);

% Find junction length difference
delta_junction = junction_after - junction_bf;

% Determine whether the cells are of the same type
same_type = cell_id == neighbor_id;

deltaE = ...
				homophilic(delta_junction)*same_type + ...
				heterophilic(delta_junction)*~same_type + ...
				sigma_area(area_cell - 1 + area_perimeter + 1) ...
				;

otherwise
				error('Incorrect number of inputs: either 2 or 4.');
end

end

