%% Need to figure out how to get a 'zero' pixel... (Backgrounds)
% 
% hexagons = imread('~/Desktop/hexagon.gif');
% hexagons = hexagons > 1;
% L = bwlabeln(hexagons,4);
% initial_lattice = imdilate(L,true(3));
% initial_lattice = initial_lattice - 1;
% initial_lattice(initial_lattice == -1) = 0;

%%

cell_size = 5;
p.energy_function = @differential_adhesion;
ad1 = 10;
ad2 = 8;
ad12 = 6;
bg1 = 12;
bg2= 12;
sigma_area = 1;
targ_area = cell_size^2;

T = 5;

p.energy_parameters = [ad1 ad2 ad12 bg1 bg2 sigma_area targ_area];

p.simulation_temperature = T;
p.boundary_condition = 'zero';
p.boundary_size = 50;

%% generate lattice
N = 400;
mat = ones(cell_size);
index = [];
this_row = [];
for i = 1:N
    this_row = [this_row mat*i];
    if mod(i,sqrt(N)) == 0;
        index = cat(1,index,this_row);
        this_row = [];
    end
end

initial_lattice = index;
identity = [ones(1,floor(N/2)) ones(1,ceil(N/2))*2];
identity = identity(randperm(N));
initial_lattice = make_lattice_bounds(initial_lattice,p.boundary_condition,p.boundary_size);
p.identity = identity;
l0 = initial_lattice;

%%
RESET = 0;

if RESET
    j = 1;
    lattice_history = [];
    lattice = initial_lattice;
    energy = 0;
else
    j = j + 1;
    initial_lattice = lattice;
end
max_time = numel(lattice)*50;

energy_history = zeros(1,max_time);
for i = 1:max_time
    energy_history(i) = energy;
%     tic
    [lattice,energy] = potts_step(lattice,energy,p);
%     toc
end

lattice_history = cat(3,lattice_history,lattice);

figure,imagesc(visualize_cell_type(initial_lattice,identity))
figure,imagesc(visualize_cell_type(lattice,identity))

figure,plot(energy_history);

figure,imagesc(label2rgb(initial_lattice,'jet','k','shuffle'));
figure,imagesc(label2rgb(lattice,'jet','k','shuffle'));
