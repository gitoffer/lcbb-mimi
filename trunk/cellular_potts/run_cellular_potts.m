
initial_lattice = ...
    [[1 1 1 2 2 2 3 3 3]; ...
    [[1 1 1 2 2 2 3 3 3]; ...
    [[1 1 1 2 2 2 3 3 3]; ...
    [4 4 4 5 5 5 6 6 6 ]; ...
    [4 4 4 5 5 5 6 6 6 ]; ...
    [4 4 4 5 5 5 6 6 6 ]; ...
    [7 7 7 8 8 8 9 9 9 ]];
    [7 7 7 8 8 8 9 9 9 ]];
    [7 7 7 8 8 8 9 9 9 ]];

identity = [1 2 1 2 1 2 1 2 1];

p.energy_function = @differential_adhesion;
p.energy_parameters = [1 0 10 9 0 12];
p.energy_parameters(6) = 2*sqrt(pi*p.energy_parameters(4));
p.simulation_temperature = 100;
p.identity = identity;

max_time = 1000;

lattice = initial_lattice;
% Actually this probably doesn't matter... set ground state energy to 0?
%energy = feval(lattice,p);
energy = 0;

lattice_history = zeros([size(lattice),max_time]);
energy_history = zeros(max_time);

for i = 1:max_time
    lattice_history(:,:,i) = lattice;
    energy_history(i) = energy;
    [lattice,energy] = potts_step(lattice,energy,p);
end