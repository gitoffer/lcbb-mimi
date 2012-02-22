function deltaE = differential_adhesion(lattice,p,cell,neighbor)
%DIFFERENTIAL_ADHESION Calculates the total energy (or a change in energy)
% for a given cell-lattice, according to the differential adhesion model.
%
% Reference: Glazier, Graner, 1993, PRE.
%
% If given only the cell-lattice and the parameter structure, will yield the
% total energy. However if two pairs of pixel coordinates are given, will
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
        ad_12 = p.energy_parameters(3);
        bg_1 = p.energy_parameters(4);
        bg_2 = p.energy_parameters(5);
        sigma_area = p.energy_parameters(6);
        target_area = p.energy_parameters(7);
        
        i = cell.i;
        j = cell.j;
        
        n = neighbor.i;
        m = neighbor.j;
        
        cell_number = lattice(i,j);
        neighbor_number = lattice(n,m);
        if cell_number == neighbor_number
            keyboard
        end
        
        % calculate cell area
        area_cell = numel(lattice(lattice == cell_number));
        area_neighbor = numel(lattice(lattice == neighbor_number));
        
        % Find deviation from target
        dev_A_cell_before = area_cell - target_area;
        dev_A_cell_after = area_cell - 1 - target_area;
        dev_A_neighbor_before = area_neighbor - target_area;
        dev_A_neighbor_after = area_neighbor + 1 - target_area;
        
        % Determine whether the cells are of the same type
        if cell_number == 0
            cell_id = 0;
            area_elasticity = sigma_area*(dev_A_neighbor_after^2 - dev_A_neighbor_before^2);
            neighbor_id = p.identity(neighbor_number);
        elseif neighbor_number == 0
            neighbor_id = 0;
            area_elasticity = sigma_area*(dev_A_cell_after^2 - dev_A_cell_before^2);
            cell_id = p.identity(cell_number);
        else
            cell_id = p.identity(cell_number);
            neighbor_id = p.identity(neighbor_number);
            area_elasticity = sigma_area*(dev_A_cell_after^2 - dev_A_cell_before^2 ...
                + dev_A_neighbor_after^2 - dev_A_neighbor_before^2);
        end
        
        % Find adhesion connection before
        same_type = (cell_id == neighbor_id);
        if same_type
            switch cell_id
                case 1, adhesion_before = ad_1; % Jll
                case 2, adhesion_before = ad_2; % Jdd
                otherwise
                    keyboard
            end
        else
            switch cell_id + neighbor_id
                case 3, adhesion_before = ad_12; %Jld
                case 1, adhesion_before = bg_1; %JlM
                case 2, adhesion_before = bg_2; %JdM
                otherwise
                    keyboard
            end
        end
        
        % Find adhesion energy after
        switch neighbor_id
            case 0, adhesion_after = 0;
            case 1, adhesion_after = ad_1;
            case 2, adhesion_after = ad_2;
            otherwise
                keyboard
        end
        
        deltaE = (adhesion_after - adhesion_before) + area_elasticity;
        
    otherwise
        error('Incorrect number of inputs: either 2 or 4.');
end

end
