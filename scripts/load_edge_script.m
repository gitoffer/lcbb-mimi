%%Load data

clear input input_twist input_cta;

input(1).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/2color_4 013012/Measurements';
input(1).zslice = 1; input(1).actual_z = 5;
input(1).tref = 15; input(1).t0 = 0;
input(1).dt = 6.7; input(1).um_per_px = .1806;
input(1).X = 1044; input(1).Y = 400; input(1).T = 60;

input(2).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements';
input(2).zslice = 2; input(2).actual_z = 5;
input(2).tref = 30; input(2).t0 = 0;
input(2).dt = 7.4; input(2).um_per_px = .1806;
input(2).X = 1000; input(2).Y = 400; input(2).T = 65; 

input(3).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/101512 SqhGap 1/Measurements';
input(3).zslice = 1; input(3).actual_z = 4;
input(3).tref = 45; input(3).t0 = 15; input(3).ignore_list = [];
input(3).dt = 6.1; input(3).um_per_px = 0.1732535;
input(3).X = 400; input(3).Y = 1000; input(3).T = 80;

input(4).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/102512 Embryo 1/Measurements';
input(4).zslice = 1; input(4).actual_z = 4;
input(4).tref = 40; input(4).t0 = 0; input(4).ignore_list = [];
input(4).dt = 7.6; input(4).um_per_px = 0.1732535;
input(4).X = 400; input(4).Y = 1000; input(4).T = 80;

input(5).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/110712 SqhGap 1/Measurements';
input(5).zslice = 2; input(5).actual_z = 4;
input(5).tref = 90; input(5).t0 = 0; input(5).ignore_list = [];
input(5).dt = 7; input(5).um_per_px = 0.1596724;
input(5).X = 400; input(5).Y = 1000; input(5).T = 130;

input(6).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Twist RNAi Series006/Measurements';
input(6).zslice = 1; input(6).actual_z = 7;
input(6).tref = 50; input(6).t0 = 0; input(6).ignore_list = []; %embryo4
input(6).dt = 8; input(6).um_per_px = [];
input(6).X = 1024; input(6).Y = 380; input(6).T = 100;

input(7).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Twist RNAi Series022/Measurements';
input(7).zslice = 1; input(7).actual_z = 7;
input(7).tref = 50; input(7).t0 = 0; input(7).ignore_list = [];
input(7).dt = 8; input(7).um_per_px = [];
input(7).X = 1024; input(7).Y = 380; input(7).T = 70;

input_cta(1).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/090307 cta Spider/Measurements';
input_cta(1).zslice = 1; input_cta(1).actual_z = 9;
input_cta(1).tref = 1; input_cta(1).ignore_list = [];
input_cta(1).dt = 1; input_cta(1).um_per_px = .2;
input_cta(1).T = 70;

msmts2make = {'myosin','membranes--basic_2d--area', ...
    'Membranes--vertices--Vertex-y','Membranes--vertices--Vertex-x',...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Membranes--vertices--Identity of neighbors-all', ...
    'Myosin--myosin_intensity--Myosin intensity fuzzy',...
    'Membranes--ellipse_properties--Anisotropy-xy'};

%%

EDGEstack = load_edge_data({input.folder2load},msmts2make{:});
EDGEstack_cta = load_edge_data({input_cta.folder2load},msmts2make{:});
beep;

%% Select which stack to load
in = input;
stack2load = EDGEstack;

%% Load embryos

num_embryos = numel(in);

[areas,IDs,master_time] = extract_msmt_data(stack2load,'area','on',in);
myosins = extract_msmt_data(stack2load,'myosin intensity fuzzy','on',in);
centroids_x = extract_msmt_data(stack2load,'centroid-x','on',in);
centroids_y = extract_msmt_data(stack2load,'centroid-y','on',in);
neighborID = extract_msmt_data(stack2load,'identity of neighbors-all','off',in);
vertices_x = extract_msmt_data(stack2load,'vertex-x','off',in);
vertices_y = extract_msmt_data(stack2load,'vertex-y','off',in);
% majors = extract_msmt_data(stack2load,'major axis','on',input);
% minors = extract_msmt_data(stack2load,'minor axis','on',input);
% orientations = extract_msmt_data(stack2load,'identity of neighbors','off',input);
% anisotropies = extract_msmt_data(stack2load,'anisotropy-xy','on',input);

% coronal_areas = get_corona_measurement(areas,neighborID,tref);
% coronal_myosins = get_corona_measurement(myosins,neighborID);
num_frames = size(areas,1);

areas_sm = smooth2a(areas,1,0);
myosins_sm = smooth2a(squeeze(myosins),1,0);
% myosins_fuzzy_sm = smooth2a(squeeze(myosins_fuzzy),1,0);
% coronal_areas_sm = smooth2a(coronal_areas,1,0);
% coronal_myosins_sm = smooth2a(coronal_myosins,1,0);

areas_rate = -central_diff_multi(areas_sm,1:num_frames);
% myosins_rate_fuzzy = central_diff_multi(myosins_fuzzy_sm,1:num_frames);
myosins_rate = central_diff_multi(myosins_sm,1:num_frames);
% anisotropies_rate = central_diff_multi(anisotropies);
% coronal_areas_rate = -central_diff_multi(coronal_areas_sm);
% coronal_myosins_rate = central_diff_multi(coronal_myosins_sm);

num_cells = zeros(1,num_embryos);
for i = 1:num_embryos
    foo = [IDs.which];
    num_cells(i) = numel(foo(foo==i));
end

