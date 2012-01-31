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
        sigma_area = p.energy_parameters(3);
        target_area = p.energy_parameters(4);
        sigma_perim = p.energy_parameters(5);
        target_perim = p.energy_parameters(6);
        
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
        perimeters = regionprops(lattice,'Perimeter');
        perimeter_cell = perimeters(cell_number).Perimeter;
        perimeter_neighbor = perimeters(neighbor_number).Perimeter;
        
        % Thicken the cell areas by 1, and where the thickened cells overlap
        % is defined to be the contact boundary (called junction)
        bound_cell = bwmorph(lattice == cell_number,'thicken',1);
        bound_neighbor = bwmorph(lattice == neighbor_number,'thicken',1);
        junction_bf = numel(bound_cell & bound_neighbor);
        
        % Now perform swap and calculate readjusted geometry
        candidate_lattice = lattice;
        candidate_lattice(i,j) = neighbor_number;
        
        % Recalculate junction length
        bound_cell = bwmorph(candidate_lattice == cell_number,'thicken',1);
        bound_neighbor = bwmorph(candidate_lattice == neighbor_number,'thicken',1);
        junction_after = numel(bound_cell & bound_neighbor);
        perimeters = regionprops(lattice,'Perimeter');
        perimeter_cell_after = perimeters(cell_number).Perimeter;
        perimeter_neighbor_after = perimeters(neighbor_number).Perimeter;
        
        % Find junction length differences
        delta_junction = junction_after - junction_bf;
        % Find deviation from target
        dev_A_cell_before = area_cell - target_area;
        dev_A_cell_after = area_cell - 1 - target_area;
        dev_A_neighbor_before = area_neighbor - target_area;
        dev_A_neighbor_after = area_neighbor + 1 - target_area;
        
        dev_P_cell_before = perimeter_cell - target_perim;
        dev_P_cell_after = perimeter_cell_after - target_perim;
        dev_P_neighbor_before = perimeter_neighbor - target_perim;
        dev_P_neighbor_after = perimeter_neighbor_after - target_perim;
        
        % Determine whether the cells are of the same type
        same_type = cell_id == neighbor_id;
        
        % deltaE = E_final - E_initial
        deltaE = ...
            - homophilic*(delta_junction)*same_type ...
            - heterophilic*(delta_junction)*~same_type ...
            + sigma_perim*(dev_P_cell_after^2 - dev_P_cell_before^2 ...
                + dev_P_neighbor_after^2 - dev_P_neighbor_before^2) ...
            + sigma_area*(dev_A_cell_after^2 - dev_A_cell_before^2 ...
                + dev_A_neighbor_after^2 - dev_A_neighbor_before^2) ...
            ;
        
    otherwise
        error('Incorrect number of inputs: either 2 or 4.');
end

end

