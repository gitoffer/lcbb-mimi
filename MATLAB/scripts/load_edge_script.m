%LOAD_EDGE_SCRIPT
%
% Pipeline for loading data from the MATLAB/EDGE-1.06 folder into various file
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

input(1).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/01-30-2012 SqhGap 4/Measurements';
input(1).zslice = 1;
input(1).actual_z = 5;
input(1).tref = 15;
input(1).t0 = 0;
input(1).dt = 6.7;
input(1).um_per_px = .1806;
input(1).X = 1044;
input(1).Y = 400;
input(1).T = 60;
input(1).yref = 32; %um
input(1).embryoID = 1;
input(1).last_segmented = 50;
input(1).fixed = 0;
input(1).ignore_list = [];

input(2).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/01-30-2012 SqhGap 7/Measurements';
input(2).zslice = 2;
input(2).actual_z = 5;
input(2).tref = 30;
input(2).t0 = 0;
input(2).dt = 7.4;
input(2).um_per_px = 0.18921;
input(2).X = 1000;
input(2).Y = 400;
input(2).T = 65; 
input(2).yref = 41; %um
input(2).embryoID = 2;
input(2).last_segmented = 60;
input(2).fixed = 0;
input(2).ignore_list = [];

input(3).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/10-15-2012 SqhGap 1/Measurements';
input(3).zslice = 1;
input(3).actual_z = 4;
input(3).tref = 45;
input(3).t0 = 15;
input(3).ignore_list = [];
input(3).dt = 6.1;
input(3).um_per_px = 0.1732535;
input(3).X = 1000;
input(3).Y = 400;
input(3).T = 80;
input(3).yref = 37; %um
input(3).embryoID = 3;
input(3).last_segmented = 90;
input(3).fixed = 0;
input(3).ignore_list = [];

input(4).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/10-25-2012 SqhGap 1/Measurements';
input(4).zslice = 1;
input(4).actual_z = 4;
input(4).tref = 40;
input(4).t0 = 0;
input(4).ignore_list = [];
input(4).dt = 7.6;
input(4).um_per_px = 0.17969;
input(4).X = 1000;
input(4).Y = 400;
input(4).T = 80;
input(4).yref = 43; %um
input(4).embryoID = 4;
input(4).fixed = 0;
input(4).last_segmented = 65;

input(5).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/11-07-2012 SqhGap 1/Measurements';
input(5).zslice = 2;
input(5).actual_z = 4;
input(5).tref = 90;
input(5).t0 = 0;
input(5).ignore_list = [];
input(5).dt = 7;
input(5).um_per_px = 0.1596724;
input(5).X = 1000;
input(5).Y = 400;
input(5).T = 130;
input(5).yref = 30; %um
input(5).embryoID = 5;
input(5).fixed = 0;
input(5).last_segmented = 125;

% twist

input(6).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/Twist RNAi Series006/Measurements';
input(6).zslice = 1;
input(6).actual_z = 7;
input(6).tref = 50;
input(6).t0 = 0;
input(6).ignore_list = []; %embryo4
input(6).dt = 8;
input(6).um_per_px = 0.141;
input(6).X = 1024; 
input(6).Y = 380;
input(6).T = 100;
input(6).yref = 0; %um
input(6).embryoID = 6;
input(6).fixed = 0;
input(6).last_segmented = 100;

input(7).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/Twist RNAi Series022/Measurements';
input(7).zslice = 1;
input(7).actual_z = 7;
input(7).tref = 50;
input(7).t0 = 0;
input(7).ignore_list = [];
input(7).dt = 8;
input(7).um_per_px = 0.141;
input(7).X = 1024;
input(7).Y = 380;
input(7).T = 70;
input(7).yref = 0; %um
input(7).embryoID = 7;
input(7).fixed = 0;
input(7).last_segmented = 70;

input(8).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/12-04-2013 SqhGap twi RNAi/Measurements';
input(8).zslice = 1;
input(8).actual_z = 6;
input(8).tref = 1;
input(8).t0 = 0;
input(8).ignore_list = [];
input(8).dt = 7.45;
input(8).um_per_px = 0.21255;
input(8).X = 1000;
input(8).Y = 400;
input(8).T = 100;
input(8).fixed = 0;
input(8).yref = 0;
input(8).embryoID = 8;
input(8).last_segmented = 50;

input(9).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/01-15-2014 twi RNAi SqhGap 7/Measurements';
input(9).zslice = 2;
input(9).actual_z = 5;
input(9).tref = 1;
input(9).t0 = 0;
input(9).ignore_list = [];
input(9).dt = 6.961;
input(9).um_per_px = 0.17484;
input(9).X = 1000;
input(9).Y = 400;
input(9).T = 85;
input(9).yref = 0; %um
input(9).embryoID = 9;
input(9).fixed = 0;
input(9).last_segmented = 80;

input(10).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/01-24-2014 twi RNAi SqhGap 5/Measurements';
input(10).zslice = 2;
input(10).actual_z = 7;
input(10).tref = 1;
input(10).t0 = 0;
input(10).ignore_list = [];
input(10).dt = 7.56;
input(10).um_per_px = 0.1844619;
input(10).X = 1000;
input(10).Y = 400;
input(10).T = 100;
input(10).yref = 0; %um
input(10).embryoID = 10;
input(10).fixed = 0;
input(10).last_segmented = 90;

% control injection

input(11).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/02-12-2014 Control SqhGap 1/Measurements';
input(11).zslice = 2;
input(11).actual_z = 7;
input(11).tref = 30;
input(11).t0 = 0;
input(11).ignore_list = [];
input(11).dt = 7.56;
input(11).um_per_px = 0.19385;
input(11).X = 1000;
input(11).Y = 400;
input(11).T = 80;
input(11).yref = 0; %um
input(11).embryoID = 11;
input(11).fixed = 0;
input(11).last_segmented = 70;

input(12).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/02-12-2014 Control SqhGap 4/Measurements';
input(12).zslice = 2;
input(12).actual_z = 7;
input(12).tref = 15;
input(12).t0 = 0;
input(12).ignore_list = [];
input(12).dt = 7.395;
input(12).um_per_px = 0.19385;
input(12).X = 1000;
input(12).Y = 400;
input(12).T = 59;
input(12).yref = 0; %um
input(12).embryoID = 12;
input(12).fixed = 0;
input(12).last_segmented = 59;

input(13).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/02-12-2014 Control SqhGap 2/Measurements';
input(13).zslice = 1;
input(13).actual_z = 8;
input(13).tref = 15;
input(13).t0 = 0;
input(13).ignore_list = [];
input(13).dt = 6.789;
input(13).um_per_px = 0.19385;
input(13).X = 1000;
input(13).Y = 400;
input(13).T = 82;
input(13).yref = 0; %um
input(13).embryoID = 13;
input(13).fixed = 0;
input(13).last_segmented = 80;


% % cta

input(14).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/cta_11_10_12/Measurements';
input(14).zslice = 1;
input(14).actual_z = 5;
input(14).tref = 40;
input(14).t0 = 14;
input(14).ignore_list = [];
input(14).dt = 6.804;
input(14).um_per_px = 0.2125;
input(14).X = 1000;
input(14).Y = 400;
input(14).T = 100;
input(14).yref = 0; %um
input(14).embryoID = 14;
input(14).fixed = 0;
input(14).last_segmented = 95;
% 
% input(12).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/cta_1_29_13_3/Measurements';
% input(12).zslice = 1;
% input(12).actual_z = 6;
% input(12).tref = 15;
% input(12).t0 = 0;
% input(12).ignore_list = [];
% input(12).dt = 7.5;
% input(12).um_per_px = 0.1812;
% input(12).X = 1000;
% input(12).Y = 400;
% input(12).T = 45;
% input(12).yref = 0; %um
% input(12).embryoID = 12;
% input(12).fixed = 0;
% input(12).last_segmented = 45;

% princeton dataset
input_princeton(1).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/Twist RNAi Series006/Measurements';
input_princeton(1).zslice = 1;
input_princeton(1).actual_z = 7;
input_princeton(1).tref = 50;
input_princeton(1).t0 = 0;
input_princeton(1).ignore_list = []; %embryo4
input_princeton(1).dt = 8;
input_princeton(1).um_per_px = 0.141;
input_princeton(1).X = 1024; 
input_princeton(1).Y = 380;
input_princeton(1).T = 100;
input_princeton(1).yref = 0; %um
input_princeton(1).embryoID = 1;
input_princeton(1).fixed = 0;
input_princeton(1).last_segmented = 100;

input_princeton(2).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/Twist RNAi Series022/Measurements';
input_princeton(2).zslice = 1;
input_princeton(2).actual_z = 7;
input_princeton(2).tref = 50;
input_princeton(2).t0 = 0;
input_princeton(2).ignore_list = [];
input_princeton(2).dt = 8;
input_princeton(2).um_per_px = 0.141;
input_princeton(2).X = 1024;
input_princeton(2).Y = 380;
input_princeton(2).T = 70;
input_princeton(2).yref = 0; %um
input_princeton(2).embryoID = 2;
input_princeton(2).fixed = 0;
input_princeton(2).last_segmented = 70;

input_princeton(3).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/Control Inject Series001/Measurements';
input_princeton(3).zslice = 1;
input_princeton(3).actual_z = 8;
input_princeton(3).tref = 25;
input_princeton(3).t0 = 0;
input_princeton(3).ignore_list = [];
input_princeton(3).dt = 8;
input_princeton(3).um_per_px = 0.141;
input_princeton(3).X = 1000;
input_princeton(3).Y = 400;
input_princeton(3).T = 90;
input_princeton(3).yref = 0; %um
input_princeton(3).embryoID = 3;
input_princeton(3).fixed = 0;
input_princeton(3).last_segmented = 90;

input_princeton(4).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/Control Inject Series002/Measurements';
input_princeton(4).zslice = 1;
input_princeton(4).actual_z = 8;
input_princeton(4).tref = 25;
input_princeton(4).t0 = 0;
input_princeton(4).ignore_list = [];
input_princeton(4).dt = 8;
input_princeton(4).um_per_px = 0.180;
input_princeton(4).X = 1000;
input_princeton(4).Y = 400;
input_princeton(4).T = 60;
input_princeton(4).yref = 0; %um
input_princeton(4).embryoID = 4;
input_princeton(4).fixed = 0;
input_princeton(4).last_segmented = 55;

% input_rok(1).folder2load = '~/Documents/MATLAB/EDGE-1.06/DATA_GUI/080213 RokGap 1/Measurements';
% input_rok(1).zslice = 2;
% input_rok(1).actual_z = 4;
% input_rok(1).tref = 50;
% input_rok(1).yref = 1;
% input_rok(1).t0 = 0;
% input_rok(1).last_segmented = 80;
% input_rok(1).ignore_list = [];
% input_rok(1).dt = 6;
% input_rok(1).um_per_px = 0.2;
% input_rok(1).X = 900;
% input_rok(1).Y = 400;
% input_rok(1).T = 80;
% input_rok(1).fixed = 0;
% input_rok(1).embryoID = 1;

msmts2make = {'membranes--basic_2d--area', ...
    'Membranes--vertices--Vertex-y','Membranes--vertices--Vertex-x',...
    'Membranes--vertices--Vertex-y-micron','Membranes--vertices--Vertex-x-micron',...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Membranes--vertices--Identity of neighbors-all', ...
    'Myosin--myosin_intensity--Myosin intensity',...
    'Myosin--myosin_intensity--Myosin intensity fuzzy',...
    'Myosin--myosin_radial--Ring 1',...
    'Myosin--myosin_radial--Ring 2',...
    'Myosin--myosin_radial--Ring 3',...
    'Myosin--myosin_radial--Inside',...
    'Myosin--myosin_structure--fraction of cell area',...
    'Myosin--myosin_structure--fraction of coronal area'
    };

msmts2make_rok = {'membranes--basic_2d--area', ...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Membranes--vertices--Vertex-y','Membranes--vertices--Vertex-x',...
    'Membranes--vertices--Identity of neighbors-all', ...
    'RhoKinase--rok_intensity--Rok intensity',...
    'RhoKinase--rok_intensity--Rok - deviation',...
    'RhoKinase--rok_intensity--Rok - radial moment',...
    'RhoKinase--rok_intensity--Rok - center of mass - x',...
    'RhoKinase--rok_intensity--Rok - center of mass - y',...
    'RhoKinaseThresholded--rok_intensity_th--Rok_th intensity',...
    'RhoKinaseThresholded--rok_intensity_th--Rok_th - deviation',...
    'RhoKinaseThresholded--rok_intensity_th--Rok_th - center of mass - x',...
    'RhoKinaseThresholded--rok_intensity_th--Rok_th - center of mass - y',...
    'RhoKinaseThresholded--rok_intensity_th--Rok_th - radial moment'};

msmts2make_princeton = { ...
    'Membranes--basic_2d--area', ...
    'Membranes--vertices--Vertex-x','Membranes--vertices--Vertex-y', ...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Myosin--myosin_intensity--Myosin intensity' ...
    };

msmts2make_twi = { ...
    'Membranes--basic_2d--area', ...
    'Membranes--vertices--Vertex-x','Membranes--vertices--Vertex-y', ...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Myosin--myosin_intensity--Myosin intensity', ...
    'Membranes--vertices--identity of neighbors-all'...
    };

%% Load data (will beep when done)

EDGEstack = load_edge_data({input.folder2load},msmts2make_twi{:});
% EDGEstack_cta = load_edge_data({input_cta.folder2load},msmts2make{:});
% EDGEstack_princeton = load_edge_data({input_princeton.folder2load},msmts2make_princeton{:});
% EDGEstack_twi = load_edge_data({input_twi.folder2load},msmts2make_twi{:});
% EDGEstack_rok = load_edge_data({input_rok.folder2load},msmts2make_rok{:});
beep;

%% Select which stack to load (esp. if there are multiple types of embryos)

in = input;
stack2load = EDGEstack;

%% Load into various stand-alone files (e.g. areas, myosins)

%% membrane
num_embryos = numel(in);

[areas,IDs,dev_time] = extract_msmt_data(stack2load,'area','on',in);
centroids_x = extract_msmt_data(stack2load,'centroid-x','on',in);
centroids_y = extract_msmt_data(stack2load,'centroid-y','on',in);
neighborID = extract_msmt_data(stack2load,'identity of neighbors-all','off',in);
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
% myosin_dist2border = extract_msmt_data(stack2load,'distance to border','off',in);
% [myosin_dist2border{cellfun(@isempty,myosin_dist2border)}] = deal(NaN);
% myosin_dist2border = cellfun(@nanmean,myosin_dist2border);
% myosin_size = extract_msmt_data(stack2load,'myosin spot size','off',in);
% myosin_number = extract_msmt_data(stack2load,'number of myosin spots','off',in);
% myosin_fraction = extract_msmt_data(stack2load,'fraction of cell area','on',in);
% myosin_coronal_frac = extract_msmt_data(stack2load,'fraction of coronal area','on',in);
% myosin_connection = extract_msmt_data(stack2load,'# cells connected by myosin','on',in);
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
cells_raw = embryo2cell(embryo_stack);
