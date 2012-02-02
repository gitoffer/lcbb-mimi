function [neighbor,flag] = draw_random_neighbor(lattice,cell)
%DRAW_RANDOM_NEIGHBOR Given a cell-lattice and a pixel coordinate, draw at
%random a pixel belonging to a cell-identity different from the given pixel
%from the 8-connected neighboring pixels. If a pixel whose neighbors are
%all of the same identity, an error flag is raised.
%
% SYNOPSIS: [neighbor,err] = draw_random_neighbor(lattice,cell)
%
% INPUT: lattice - a 2D matrix where eachh pixel value is an integer (or 0)
%                  indicating to which cell that pixel belongs.
%        cell.i - the first coordinate of the given pixel
%        cell.j - the second coordinate of the given pixel
% OUTPUT: neighbor.i - the first coordinate of the drawn neighbor
%         neighbor.j - the second coordinate of the drawn neighbor
%
% xies@mit.edu Feb 2012.

flag = 0;
cell_n = cell.i;
cell_m = cell.j;

cell_number = lattice(cell_n,cell_m);
[N,M] = size(lattice);

% Take care of border cells -- 
if cell_n == N
    lattice = lattice([2:end,1],:);
    left = cell_n - 2;
    right = cell_n;
elseif cell_n == 1
    lattice = lattice([N,1:end-1],:);
    left = cell_n;
    right = cell_n + 2;
else
    left = cell_n - 1;
    right = cell_n + 1;
end
if cell_m == M
    lattice = lattice(:,[2:end,1]);
    top = cell_m - 2;
    bottom = cell_m;
elseif cell_m == 1
    lattice = lattice(:,[M,1:end-1]);
    top = cell_m;
    bottom = cell_m + 2;
else
    top = cell_m - 1;
    bottom = cell_m + 1;
end

% Find 'box' of 8 neighboring pixels
box = lattice(left:right,top:bottom);
% neighbor_pixels = box.*(box~=cell_number);
% Count how many non-self cells there are
num_neighbor = numel(box(box ~= cell_number));
if num_neighbor == 0
    flag = 1;
    neighbor = [];
    return
end

neighborhood = [[1 4 7];[2 5 8];[3 6 9]];
neighborhood = neighborhood(box~=cell_number);
random_neighbor = neighborhood(randi(num_neighbor));

switch random_neighbor
	case 1
		neighbor_i = cell_n - 1; neighbor_j = cell_m - 1;
	case 2
		neighbor_i = cell_n; neighbor_j = cell_m - 1;
	case 3
		neighbor_i = cell_n + 1; neighbor_j = cell_m - 1;
	case 4
		neighbor_i = cell_n - 1; neighbor_j = cell_m;
	case 6
		neighbor_i = cell_n + 1; neighbor_j = cell_m;
	case 7
		neighbor_i = cell_n - 1; neighbor_j = cell_m + 1;
	case 8
		neighbor_i = cell_n; neighbor_j = cell_m + 1;
	case 9
		neighbor_i = cell_n + 1; neighbor_j = cell_m + 1;
	otherwise
		error('---');
end

if neighbor_i > N
		neighbor_i = 1;
elseif neighbor_i < 1
		neighbor_i = N;
end
if neighbor_j > M
		neighbor_j = 1;
elseif neighbor_j < 1
		neighbor_j = M;
end

neighbor.i = neighbor_i;
neighbor.j = neighbor_j;
