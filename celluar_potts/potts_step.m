function [updated_lattice,updated_energy] = potts_step(current_lattice,energy_current,p)

% Parse parameters
f = p.energy_function;
T = p.simulation_temperature;

% Set up periodic boundary (pad array)
current_lattice = make_periodic_bounds(current_lattice);

% Pick a random cell and a random neighbor
cell = draw_random_cell(current_lattice);
neighbor = draw_random_neighbor(cell);

% Temporarily switch pixel-identity of 'cell' and 'neighbor'
% candidate_lattice = current_lattice;
% tmp = current_lattice(cell.i,cell.j);
% candidate_lattice(cell.i,cell.j) = ...
%     current_lattice(neighbor.i,neighbor.j);
% candidate_lattice(neighbor.i,neighbor.j) = tmp;
% Reevaluate energy functional
energy_after = feval( ...
    f,candidate_lattice,cell,neighbor,parameters);

% Find change in energy and calculate acceptance probability (boltzmann)
deltaE = energy_after - energy_current;
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