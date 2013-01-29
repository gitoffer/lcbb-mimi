%Script to load data from EDGE

% Folder where the EDGE Measurements are kept
input(1).folder2load = ...
    '~/Documents/MATLAB/EDGE/DATA_GUI/2color_4 013012/Measurements';
% The slice number (out of all EXPORTED EDGE slices) that you want.
input(1).zslice = 2;
% The time by which you want to align embryos; put down 1 if there's only
% one embryo.
input(1).tref = 1;
% You can choose to ignore certain cells by putting their ID in the ignore
% list
input(1).ignore_list = [];
% The resolution of imaging (dt = time, um_per_px = space)
input(1).dt = 6.7; input(1).um_per_px = .1806;
% Size of the original image
input(1).X = 1044; input(1).Y = 400;

%% Loads all .mat files from EDGE into a single structure

EDGEstack = load_edge_data({input.folder2load},msmt2make{:});

%% Extracts the EDGEstack structure into individual measurements

% The number of embryos in the output... useful if you want to load and
% align multiple embryos
num_embryos = numel(output);

[areas,num_cells,t,c,IDs] = extract_msmt_data(EDGEstack,'area','on',input);
myosins = extract_msmt_data(EDGEstack,'myosin intensity','on',input);
vertices_x = extract_msmt_data(EDGEstack,'vertex-x',off',input);
vertices_y = extract_msmt_data(EDGEstack,'vertex-y',off',input);

% Get the total number of frames
num_frames = size(areas,1);

% Generate a matrix of real-time for each frame of image
time_mat = zeros(size(myosins_sm));
for i = 1:num_embryos
    time_mat(:,c==i) = repmat((t.*input(i).dt)',[1 numel(c(c==i))]);
end

%%