function deltaE = differential_adhesion(lattice,p,cell,neighbor)
%DIFFERENTIAL_ADHESION Calculates the total energy (or a change in energy)
% for a given cell-lattice, according to the differential adhesion model.
%
% If given only the cell-lattice and the parameter structure, will yield the
%	total energy. However if two pairs of pixel coordinates are given, will
% calculate the change in energy if the first pixel were to become a part of
% the cell to which the second pixel belongs.
%
% SYNOPSIS: totalE = differential_adhesion(lattice, params);
%					  deltaE = differential_adhesion(lattice, params, cell_i, cell_j)
%
% INPUT: lattice - a matrix of the current configuration of cells
%				 p - parameter structure
%				 	.energy_parameters - array of energy parameters
%				  .identity - a list of the identity of each cell (for adhesion)
%					.
%
%
% xies@mit.edu. 20.415 Spring 2012.

switch nargin
    case 2
        % If there are only 2 inputs, calculate the total energy for the lattice given.
        error('Unsupported right now.')
    case 4
        % If there are 4 inputs, then cell i and cell j are given, then we only calculate the change in energy if the identity of cell i was to be replaced by that of cell j.
        
        ad_1 = p.energy_parameters(1);
        ad_2 = p.energy_parameters(2);
        hetero_adh = p.energy_parameters(3);
        sigma_area = p.energy_parameters(4);
        target_area = p.energy_parameters(5);
        sigma_perim = p.energy_parameters(6);
        target_perim = p.energy_parameters(7);
        background_interaction = p.energy_parameters(8);
        
        i = cell.i;
        j = cell.j;
        
        n = neighbor.i;
        m = neighbor.j;
        
        % Need to correct for when neighbor is on the boundary-- shift the lattice?
        
        cell_number = lattice(i,j);
        neighbor_number = lattice(n,m);
        
        % Find the identity of the cells
        if cell_number > 0
            cell_id = p.identity(cell_number);
        end
        if neighbor_number > 0
            neighbor_id = p.identity(neighbor_number);
        end
        
        % calculate cell area and perimeter
        area_cell = numel(lattice(lattice == cell_number));
        area_neighbor = numel(lattice(lattice == neighbor_number));
        perimeter_cell = numel(lattice(bwperim(lattice == cell_number)));
        perimeter_neighbor = numel(lattice(bwperim(lattice == neighbor_number)));
        
        % Thicken the cell areas by 1, and where the thickened cells overlap
        % is defined to be the contact boundary (called junction)
        bound_cell = bwmorph(lattice == cell_number,'thicken',1);
        bound_neighbor = lattice == neighbor_number;
        junction_bf = numel(bound_cell(bound_cell & bound_neighbor));
        
        % Now perform swap and calculate readjusted geometry
        candidate_lattice = lattice;
        candidate_lattice(i,j) = neighbor_number;
        
        % Recalculate junction lengths and calculate change in perimeter
        bound_cell = bwmorph(candidate_lattice == cell_number,'thicken',1);
        bound_neighbor = candidate_lattice == neighbor_number;
        junction_after = numel(bound_cell(bound_cell & bound_neighbor));
        perimeter_cell_after = numel(lattice(bwperim(candidate_lattice == cell_number)));
        perimeter_neighbor_after = ...
            numel(lattice(bwperim(candidate_lattice == neighbor_number)));
        
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
        
        if cell_number == 0
            adhesion = 0;
            perimeter_elasticity = sigma_perim*(dev_P_neighbor_after^2 - dev_P_neighbor_before^2);
            area_elasticity = sigma_area*(dev_A_neighbor_after^2 - dev_A_neighbor_before^2);
            
            bg_adhesion = background_interaction;
        elseif neighbor_number == 0
            adhesion = 0;
            perimeter_elasticity = sigma_perim*(dev_P_cell_after^2 - dev_P_cell_before^2);
            area_elasticity = sigma_area*(dev_A_cell_after^2 - dev_A_cell_before^2);
            
            bg_adhesion = background_interaction;
        else
            same_type = cell_id == neighbor_id;
            switch same_type
                case 1
                    switch cell_id
                        case 1
                            adhesion = - ad_1*delta_junction;
                        case 2
                            adhesion = - ad_2*delta_junction;
                    end
                case 0
                    adhesion = - hetero_adh*delta_junction;
            end
            bg_adhesion = 0;
            perimeter_elasticity = sigma_perim*(dev_P_cell_after^2 - dev_P_cell_before^2 ...
                + dev_P_neighbor_after^2 - dev_P_neighbor_before^2);
            area_elasticity = sigma_area*(dev_A_cell_after^2 - dev_A_cell_before^2 ...
                + dev_A_neighbor_after^2 - dev_A_neighbor_before^2);
        end
        
        deltaE = adhesion ...
            + perimeter_elasticity + area_elasticity + bg_adhesion;
        
    otherwise
        error('Incorrect number of inputs: either 2 or 4.');
end

end

