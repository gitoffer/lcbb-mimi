%%Load data

clear input input_twist;

input(1).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/2color_4 013012/Measurements';
input(1).zslice = 1; %z=5
input(1).tref = 15;
input(1).ignore_list = [1 12 14 74 24 36 79]; %embryo4
input(1).dt = 6.7; input(1).um_per_px = .1806; input(1).X = 1044;
input(1).Y = 400; input(1).T = 60;

input(2).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements';
input(2).zslice = 1; % z=6
input(2).tref = 30;
input(2).ignore_list = [1 2 3 4 5 6 7 8 46 52];
input(2).dt = 7.4; input(2).um_per_px = .1806; input(2).X = 1000;
input(2).Y = 400; input(2).T = 65; 

input(3).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/101512 SqhGap 1/Measurements';
input(3).zslice = 1; %z=4
% input(3).zslice = [2*ones(1,65), ones(1,15)];
input(3).tref = 40; input(1).ignore_list = [];
input(3).dt = 6.1; input(3).um_per_px = 0.1732535; input(3).X = 400; input(3).Y = 1000; input(3).T = 80;

% input(4).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Control inject Series001/Measurements';
% input(4).zslice = 1;
% input(4).tref = 10; input(4).ignore_list = [];
% input(4).dt = 8; input(4).um_per_px = .2; input(4).X = 560; input(4).Y = 1024; input(4).T = 70;
% 
% input(5).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Control inject Series002/Measurements';
% input(5).zslice = 1;
% input(5).tref = 10; input(5).ignore_list = [];
% input(5).dt = 8; input(5).um_per_px = .141; input(5).X = 380; input(5).Y = 1024; input(5).T = 70;

input_twist(1).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Twist RNAi Series006/Measurements';
input_twist(1).zslice = 1; input_twist(1).tref = 1; input_twist(1).ignore_list = []; %embryo4
input_twist(1).dt = 8; input_twist(1).T = 100;
input_twist(1).X = 1024; input_twist(1).Y = 380;

input_twist(2).folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Twist RNAi Series022/Measurements';
input_twist(2).zslice = 1; input_twist(2).tref = 1; input_twist(2).ignore_list = []; %embryo4
input_twist(2).dt = 8; input_twist(2).T = 70;

% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/cytoD control/Measurements';
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/control cytoD 2/Measurements';
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/UtrGFP SqhCher 1/Measurements';handle.io.save_dir = '~/Desktop/UtrGFP SqhCher 1/';zslice = 2;
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/090307 cta Spider/Measurements';handle.io.save_dir = '~/Desktop/cta Spider/';zslice = 1;ignore_list = [3 24 38 55 72 87 103 150 163];
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/spiderGFP/Measurements';handle.io.save_dir = '~/Desktop/Embryo 4';zslice = 1; tref = 1; ignorelist = [];
msmts2make = {'myosin','membranes--basic_2d--area', ...
    'Membranes--vertices--Vertex-y','Membranes--vertices--Vertex-x',...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Membranes--vertices--Identity of neighbors', ...
    'Myosin--myosin_intensity--Myosin intensity fuzzy',...
    'Membranes--ellipse_properties--Anisotropy-xy'};

%%

EDGEstack = load_edge_data({input.folder2load},msmts2make{:});
EDGEstack_twist = load_edge_data({input_twist.folder2load},msmts2make{:});
beep;

%% Load WT embryos

in = input;
num_embryos = numel(input);

[areas,IDs,master_time] = extract_msmt_data(EDGEstack,'area','on',input);
myosins = extract_msmt_data(EDGEstack,'myosin intensity fuzzy','on',input);
centroids_x = extract_msmt_data(EDGEstack,'centroid-x','on',input);
centroids_y = extract_msmt_data(EDGEstack,'centroid-y','on',input);
neighborID = extract_msmt_data(EDGEstack,'identity of neighbors','off',input);
vertices_x = extract_msmt_data(EDGEstack,'vertex-x','off',input);
vertices_y = extract_msmt_data(EDGEstack,'vertex-y','off',input);
% majors = extract_msmt_data(EDGEstack,'major axis','on',input);
% minors = extract_msmt_data(EDGEstack,'minor axis','on',input);
% orientations = extract_msmt_data(EDGEstack,'identity of neighbors','off',input);
% anisotropies = extract_msmt_data(EDGEstack,'anisotropy-xy','on',input);

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

%% Load twist embryos

in = input_twist;
num_embryos = numel(input_twist);

[areas,IDs,master_time] = extract_msmt_data(EDGEstack_twist,'area','on',input_twist);
% myosins_fuzzy = extract_msmt_data(EDGEstack_twist,'myosin intensity fuzzy','on',input_twist);
myosins = extract_msmt_data(EDGEstack_twist,'myosin intensity fuzzy','on',input_twist);
centroids_x = extract_msmt_data(EDGEstack_twist,'centroid-x','on',input_twist);
centroids_y = extract_msmt_data(EDGEstack_twist,'centroid-y','on',input_twist);
neighborID = extract_msmt_data(EDGEstack_twist,'identity of neighbors','off',input_twist);
vertices_x = extract_msmt_data(EDGEstack_twist,'vertex-x','off',input_twist);
vertices_y = extract_msmt_data(EDGEstack_twist,'vertex-y','off',input_twist);
% majors = extract_msmt_data(EDGEstack_twist,'major axis','on',input_twist);
% minors = extract_msmt_data(EDGEstack_twist,'minor axis','on',input_twist);
% orientations = extract_msmt_data(EDGEstack_twist,'orientation','on',input_twist);
anisotropies = extract_msmt_data(EDGEstack_twist,'anisotropy-xy','on',input_twist);

% myosins(:,ignore_list) = nan;
% myosins_fuzzy(:,ignore_list) = nan;
% areas(:,ignore_list) = nan;
% anisotropies(:,ignore_list) = nan;

% coronal_areas = get_corona_measurement(areas,neighborID,tref);
% coronal_myosins = get_corona_measurement(myosins,neighborID);
num_frames = size(areas,1);

areas_sm = smooth2a(areas,1,0);
myosins_sm = smooth2a(squeeze(myosins),1,0);
myosins_fuzzy_sm = smooth2a(squeeze(myosins_fuzzy),1,0);
% coronal_areas_sm = smooth2a(coronal_areas,1,0);
% coronal_myosins_sm = smooth2a(coronal_myosins,1,0);

areas_rate = -central_diff_multi(areas_sm,1:num_frames);
% myosins_rate_fuzzy = central_diff_multi(myosins_fuzzy_sm,1:num_frames);
myosins_rate = central_diff_multi(myosins_sm,1:num_frames);
% anisotropies_rate = central_diff_multi(anisotropies);
% coronal_areas_rate = -central_diff_multi(coronal_areas_sm);
% coronal_myosins_rate = central_diff_multi(coronal_myosins_sm);
% 
% max_tref = max([input_twist.tref]);
% time_mat = zeros(size(myosins_sm));
% for i = 1:num_embryos
%     time_mat(:,c==i) = repmat((t.*input_twist(i).dt)',[1 numel(c(c==i))]);
%     input_twist(i).lag = max_tref- input_twist(i).tref;
% end

num_cells = zeros(1:num_embryos);
for i = 1:num_embryos
    foo = [IDs.which];
    num_cells(i) = numel(foo(foo==i));
end

