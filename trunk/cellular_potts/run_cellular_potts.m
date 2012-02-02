%% Need to figure out how to get a 'zero' pixel... (Backgrounds)

% squares = 

hexagons = imread('~/Desktop/hexagon.gif');
hexagons = hexagons > 1;
L = bwlabeln(hexagons,4);
initial_lattice = imdilate(L,true(3));
initial_lattice = initial_lattice - 1;
initial_lattice(initial_lattice == -1) = 0;
identity = [1 2 1 2 1 2 1 2 1 2];

%%

p.energy_function = @differential_adhesion;
p.energy_parameters = [3 0 3 1300 3 NaN 0];
p.energy_parameters(6) = 2*sqrt(pi*p.energy_parameters(4));
p.simulation_temperature = 1;
p.identity = identity;
p.boundary_condition = 'zero';
p.boundary_size = 5;

max_time = 40000;

lattice = initial_lattice;
lattice = make_lattice_bounds(lattice,p.boundary_condition,p.boundary_size);
energy = 0;

lattice_history = zeros([size(lattice),max_time]);
energy_history = zeros(1,max_time);

for i = 1:max_time
    lattice_history(:,:,i) = lattice;
    energy_history(i) = energy;
    [lattice,energy] = potts_step(lattice,energy,p);
end

imsequence_color(lattice_history,'cellular_potts_2');
figure,plot(energy_history);
