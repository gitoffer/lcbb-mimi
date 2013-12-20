%LOAD_EDGE_SCRIPT
%
% Pipeline for loading data from the MATLAB/EDGE folder into various file
% structures, including stand-alone arrays (e.g. areas, myosins), as well
% as an array of embryo_structure containing the measurements as fields.
%
% If multiple embryos are loaded, will use the input.tref frame as a
% reference and generate aligned arrays for all data fields (including
% those in embryo_structure)
%
% Important outputs: embryo_stack - 1xN structure containing all loaded
%                      EDGE measurements for N embryos
%
%                    cells - cell-centric structure
%
%                    areas, myosins, etc - T_tot x N_cell num arrays (or
%                      cell-arrays for things like vertices) of the given
%                      data loaded from all embryos
%
%                    input - 1xN structure containing input file/image info
%
%                    num_cells - 1xN array of number of cells loaded from
%                      each embryo
% Feb 2013
% xies@mit.edu

%% Input the filenames and image information

clear input*;

input(1).folder2load = '~/Dropbox/EDGE/1AE 20121031_1/';
input(1).zslice = 1;
input(1).actual_z = 5;
input(1).tref = 1;
input(1).t0 = 40;
input(1).dt = 6.772;
input(1).um_per_px = 0.21255;
input(1).X = 1044;
input(1).Y = 400;
input(1).T = 150;
input(1).yref = 0; %um
input(1).embryoID = 1;
input(1).last_segmented = 50;
input(1).fixed = 0;
input(1).ignore_list = [];

input(2).folder2load = '~/Dropbox/EDGE/1AS 20120816_1/';
input(2).zslice = 1;
input(2).actual_z = 5;
input(2).tref = 1;
input(2).t0 = 0;
input(2).dt = 7.5;
input(2).um_per_px = 0.21255;
input(2).X = 1000;
input(2).Y = 400;
input(2).T = 65;
input(2).yref = 0; %um
input(2).embryoID = 2;
input(2).last_segmented = 100;
input(2).fixed = 0;
input(2).ignore_list = [];

input(3).folder2load = '~/Dropbox/EDGE/1TA 20120816_1/';
input(3).zslice = 1;
input(3).actual_z = 5;
input(3).tref = 1;
input(3).t0 = 0;
input(3).dt = 6.741;
input(3).um_per_px = 0.21255;
input(3).X = 1000;
input(3).Y = 400;
input(3).T = 82;
input(3).yref = 0; %um
input(3).embryoID = 3;
input(3).last_segmented = 80;
input(3).fixed = 0;
input(3).ignore_list = [];

input(4).folder2load = '~/Dropbox/EDGE/1TS 20130213_4/';
input(4).zslice = 1;
input(4).actual_z = 5;
input(4).tref = 1;
input(4).t0 = 0;
input(4).dt = 6.72;
input(4).um_per_px = 0.21255;
input(4).X = 1000;
input(4).Y = 400;
input(4).T = 83;
input(4).yref = 0; %um
input(4).embryoID = 4;
input(4).last_segmented = 80;
input(4).fixed = 0;
input(4).ignore_list = [];

input(5).folder2load = '~/Dropbox/EDGE/1TS 20130213_2/';
input(5).zslice = 1;
input(5).actual_z = 5;
input(5).tref = 19;
input(5).t0 = 0;
input(5).dt = 6.717;
input(5).um_per_px = 0.21255;
input(5).X = 1000;
input(5).Y = 400;
input(5).T = 80;
input(5).yref = 0; %um
input(5).embryoID = 5;
input(5).last_segmented = 80;
input(5).fixed = 0;
input(5).ignore_list = [];

msmts2make = { ...
    'Membranes--basic_2d--area', ...
    'Membranes--vertices--Vertex-x','Membranes--vertices--Vertex-y', ...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Myosin--myosin_intensity--Myosin intensity' ...
    };


%% Load data (will beep when done)

EDGEstack = load_edge_data({input.folder2load},msmts2make{:});
beep;

%% Select which stack to load (esp. if there are multiple types of embryos)

in = input;
stack2load = EDGEstack;

%% Load into various stand-alone files (e.g. areas, myosins)

%% membrane
num_embryos = numel(in);

[areas,IDs,dev_time] = extract_msmt_data(stack2load,'area','on',in);
% centroids_x = extract_msmt_data(stack2load,'centroid-x','on',in);
% centroids_y = extract_msmt_data(stack2load,'centroid-y','on',in);
% neighborID = extract_msmt_data(stack2load,'identity of neighbors-all','off',in);
vertices_x = extract_msmt_data(stack2load,'vertex-x','off',in);
vertices_y = extract_msmt_data(stack2load,'vertex-y','off',in);
% majors = extract_msmt_data(stack2load,'major axis','on',input);
% minors = extract_msmt_data(stack2load,'minor axis','on',input);
% % orientations = extract_msmt_data(stack2load,'identity of neighbors','off',input);
% anisotropies = extract_msmt_data(stack2load,'anisotropy','on',input);
% coronal_areas = get_corona_measurement(areas,neighborID);
num_frames = size(areas,1);

areas_sm = smooth2a(areas,1,0);
% rok_sm = smooth2a(squeeze(rok),1,0);
% coronal_areas_sm = smooth2a(coronal_areas,1,0);

areas_rate = -central_diff_multi(areas_sm,1:num_frames);
% anisotropies_rate = central_diff_multi(anisotropies);
% coronal_areas_rate = -central_diff_multi(coronal_areas_sm);

num_cells = zeros(1,num_embryos);
for i = 1:num_embryos
    foo = [IDs.which];
    num_cells(i) = numel(foo(foo==i));
end

%% myosin

myosins = extract_msmt_data(stack2load,'myosin intensity','on',in);
% myosin_ring1 = -extract_msmt_data(stack2load,'ring 1','on',in);
% myosin_ring2 = -extract_msmt_data(stack2load,'ring 2','on',in);
% myosin_ring3 = -extract_msmt_data(stack2load,'ring 3','on',in);
% myosin_inside = extract_msmt_data(stack2load,'inside','on',in);
% % myosin_dist2border = extract_msmt_data(stack2load,'distance to border','off',in);
% % [myosin_dist2border{cellfun(@isempty,myosin_dist2border)}] = deal(NaN);
% % myosin_dist2border = cellfun(@nanmean,myosin_dist2border);
% % myosin_size = extract_msmt_data(stack2load,'myosin spot size','off',in);
% % myosin_number = extract_msmt_data(stack2load,'number of myosin spots','off',in);
% myosin_fraction = extract_msmt_data(stack2load,'fraction of cell area','on',in);
% % myosin_coronal_frac = extract_msmt_data(stack2load,'fraction of coronal area','on',in);
% % myosin_connection = extract_msmt_data(stack2load,'# cells connected by myosin','on',in);
% myosin_inertia = extract_msmt_data(stack2load,'moment of inertia','on',in);
% myosin_deviation = extract_msmt_data(stack2load,'deviation from centroid','on',in);
% myosin_span_x = extract_msmt_data(stack2load,'span-x','on',in);
% myosin_span_y = extract_msmt_data(stack2load,'span-y','on',in);
% coronal_myosins = get_corona_measurement(myosins,neighborID);

myosins_sm = smooth2a(squeeze(myosins),2,0);
% myosins_fuzzy_sm = smooth2a(squeeze(myosins_fuzzy),1,0);
myosins_rate = central_diff_multi(myosins_sm,1:num_frames);
% myosins_rate_fuzzy = central_diff_multi(myosins_fuzzy_sm,1:num_frames);
% coronal_myosins_sm = smooth2a(coronal_myosins,1,0);
% coronal_myosins_rate = central_diff_multi(coronal_myosins_sm);

%% rok

% rok = extract_msmt_data(stack2load,'rok_th intensity','on',in);
% rok_inertia = extract_msmt_data(stack2load,'rok_th - radial moment','on',in);
% rok_dev = extract_msmt_data(stack2load,'rok_th - deviation','on',in);
% rok_rate = central_diff_multi(rok_sm,1:num_frames);

%% Load into embryo-centric structure: embryo_stack, cells

embryo_stack = edge2embryo(stack2load,in,num_cells);
% Put extra data into embryo_stack
for i = 1:num_embryos
    embryo_stack(i).myosin_intensity = myosins(:,[IDs.which] == i);
    embryo_stack(i).area_sm = areas_sm(:,[IDs.which] == i);
    embryo_stack(i).myosin_sm = myosins_sm(:,[IDs.which] == i);
end
cells = embryo2cell(embryo_stack);
