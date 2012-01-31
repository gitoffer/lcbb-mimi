function [updated_lattice,updated_energy,flag] = potts_step(current_lattice,energy_current,p)
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
[neighbor,skip] = draw_random_neighbor(current_lattice,cell);

if skip
    updated_lattice = current_lattice; updated_energy = energy_current;
    'blah'
    return
end

% Temporarily switch pixel-identity of 'cell' and 'neighbor'
% candidate_lattice = current_lattice;
% tmp = current_lattice(cell.i,cell.j);
% candidate_lattice(cell.i,cell.j) = ...
%     current_lattice(neighbor.i,neighbor.j);
% candidate_lattice(neighbor.i,neighbor.j) = tmp;
% Reevaluate delta energy functional
deltaE= feval( ...
    f,current_lattice,p,cell,neighbor);

if deltaE < 0
    updated_lattice = current_lattice;
    updated_energy = energy_current;
else
    acceptance_prob = exp(-deltaE/T);
    
    % Metropolis
    if accept(acceptance_prob)
        updated_lattice = current_lattice;
        updated_lattice(cell.i,cell.j) = ...
            current_lattice(neighbor.i,neighbor.j);
        %     updated_lattice = candidate_lattice;
        updated_energy = deltaE + energy_current;
    else
        updated_lattice = current_lattice;
        updated_energy = energy_current;
    end
end

end
