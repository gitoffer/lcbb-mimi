
initial_lattice = ...
    [[1 1 1 2 2 2 3 3 3]; ...
    [4 4 4 5 5 5 6 6 6 ]; ...
    [7 7 7 8 8 8 9 9 9 ]];

identity = [1 2 1 2 1 2 1 2 1];

p.energy_function = @differential_adhesion;
p.energy_parameters = [1 0 5];

p.simulation_tempereature = 100;
p.identity = identity;

max_time = 100;

lattice = initial_lattice;
for i = 1:max_time
    lattice = potts_step(lattice,
end
