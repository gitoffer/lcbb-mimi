function [updated_lattice,updated_energy] = potts_step(current_lattice,energy_current,p)
%POTTS_STEP Make one step according to the Metropolis-Monte Carlo cellular
%Potts algorithm.
%
% SYNPOSIS: [new_lattice,new_E] = potts_step(old_lattice,old_E,params);
%
% xies@mit.edu. 20.415 Spring 2012.

% Parse parameters
f = p.energy_function;
T = p.simulation_temperature;

% Pick a random cell-pixel and a random neighboring pixel. Will continue
% to draw until a cell-pixel with non-self neighboring pixels are drawn.

cell = draw_random_cell(current_lattice);
[neighbor,selfsame] = draw_random_neighbor(current_lattice,cell);

if selfsame
    deltaE = 0;
else
    deltaE= feval( ...
        f,current_lattice,p,cell,neighbor);
end

if deltaE <= 0
    updated_lattice = current_lattice;
    updated_lattice(cell.i,cell.j) = ...
        current_lattice(neighbor.i,neighbor.j);
    updated_energy = deltaE + energy_current;
else
    acceptance_prob = exp(-deltaE/T);
    
    % Metropolis acceptance
    if accept(acceptance_prob)
        updated_lattice = current_lattice;
        updated_lattice(cell.i,cell.j) = ...
            current_lattice(neighbor.i,neighbor.j);
        updated_energy = deltaE + energy_current;
    else
        updated_lattice = current_lattice;
        updated_energy = energy_current;
    end
end

end