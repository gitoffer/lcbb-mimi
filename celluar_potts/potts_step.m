function [updated_lattice,updated_energy] = potts_step(current_lattice,energy_current,p)
%POTTS_STEP
%
% SYNPOSIS: [new_lattice,new_E] = potts_step(old_lattice,old_E,params)
%
% xies@mit.edu. 20.415 Spring 2012.

% Parse parameters
f = p.energy_function;
T = p.simulation_temperature;


% Set up periodic boundary (pad array) NO NEED
% current_lattice = make_periodic_bounds(current_lattice);

% Pick a random cell and a random neighbor
cell = draw_random_cell(current_lattice);
neighbor = draw_random_neighbor(current_lattice,cell);

% Temporarily switch pixel-identity of 'cell' and 'neighbor'
% candidate_lattice = current_lattice;
% tmp = current_lattice(cell.i,cell.j);
% candidate_lattice(cell.i,cell.j) = ...
%     current_lattice(neighbor.i,neighbor.j);
% candidate_lattice(neighbor.i,neighbor.j) = tmp;
% Reevaluate delta energy functional
deltaE= feval( ...
    f,candidate_lattice,cell,neighbor,p);
acceptance_prob = exp(-deltaE/T);

% Metropolis step
if accept(acceptance_prob)
    updated_lattice(cell.i,cell.j) = ...
        current_lattice(neighbor.i,neighbor.j);
    %     updated_lattice = candidate_lattice;
    updated_energy = energy_after;
else
    updated_lattice = current_lattice;
    updated_energy = energy_before;
end

end
