%%Load data

% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements';handle.io.save_dir = '~/Desktop/Embryo 7';zslice = 2;
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/2color_4 013012/Measurements';handle.io.save_dir = '~/Desktop/Embryo 4';zslice = 1;
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Adam 100411 mat15/Measurements';handle.io.save_dir = '~/Desktop/Mat15';zslice = 1;
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Twist RNAi Series006/Measurements';handle.io.save_dir = '~/Desktop/Twist RNAi 6';zslice = 1;
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Twist RNAi Series022/Measurements';
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/Control inject Series002/Measurements';
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/cytoD control/Measurements';
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/control cytoD 2/Measurements';
% folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/UtrGFP SqhCher 1/Measurements';handle.io.save_dir = '~/Desktop/UtrGFP SqhCher 1/';zslice = 2;
folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/090307 cta Spider/Measurements';handle.io.save_dir = '~/Desktop/cta Spider/';zslice = 1;
msmts2make = {'myosin','area','vertex-x','vertex-y', ...
    'neighbors','ellipse_properties','centroid'};

EDGEstack = load_edge_data(folder2load,msmts2make{:});
beep;

%%

areas = extract_msmt_data(EDGEstack,'area','on',zslice);
% myosins_nonfuzzy = extract_msmt_data(EDGEstack,'myosin intensity','on',zslice);
% myosins = extract_msmt_data(EDGEstack,'myosin intensity','on',zslice);
centroids_x = extract_msmt_data(EDGEstack,'centroid-x','on',zslice);
centroids_y = extract_msmt_data(EDGEstack,'centroid-y','on',zslice);
neighborID = extract_msmt_data(EDGEstack,'identity of neighbors','off',zslice);
vertices_x = extract_msmt_data(EDGEstack,'vertex-x','off',zslice);
vertices_y = extract_msmt_data(EDGEstack,'vertex-y','off',zslice);
% majors = extract_msmt_data(EDGEstack,'major axis','on',zslice);
% minors = extract_msmt_data(EDGEstack,'minor axis','on',zslice);
% orientations = extract_msmt_data(EDGEstack,'orientation','on',zslice);
% anisotropies = extract_msmt_data(EDGEstack,'anisotropy-xy','on',zslice);
% coronal_areas = get_corona_measurement(areas,neighborID);
% coronal_myosins = get_corona_measurement(myosins,neighborID);

ignore_list = [89];
% ignore_list = [22 54 30 36];
areas(:,ignore_list) = NaN;

[num_frames,num_cells] = size(areas);

areas_sm = smooth2a(areas,1,0);
% myosins_sm = smooth2a(squeeze(myosins),1,0);
% myosins_nonfuzzy_sm = smooth2a(squeeze(myosins_nonfuzzy),1,0);
% coronal_areas_sm = smooth2a(coronal_areas,1,0);
% coronal_myosins_sm = smooth2a(coronal_myosins,1,0);

areas_rate = -central_diff_multi(areas_sm,1:num_frames);
% myosins_rate_nonfuzzy = central_diff_multi(myosins_nonfuzzy_sm,1:num_frames);
% myosins_rate = central_diff_multi(myosins_sm,1:num_frames);
% anisotropies_rate = central_diff_multi(anisotropies);
% coronal_areas_rate = -central_diff_multi(coronal_areas_sm);
% coronal_myosins_rate = central_diff_multi(coronal_myosins_sm);

%%
handle.z = zslice;
handle.EDGEstack = EDGEstack;

handle.myo_area_corr.wt = 10;

handle.neighbor_focus.wt = 10;
handle.neighbor_focus.focal_measurement = 'areas_rate';
handle.neighbor_focus.focal_name = 'constriction rate';
handle.neighbor_focus.neighbor_measurement = 'myosins_rate';
handle.neighbor_focus.neighbor_name = 'myosins rate';

handle.neighbor_focus.pearsons.display = 0;

handle.neighbor_focus.neighbor_angles.angle_data = 'pearsons';
handle.neighbor_focus.neighbor_angles.theta_bins = 0:pi/3:2*pi-pi/3;

handle.peak_gauss.display.allresponse = 0;
handle.peak_gauss.display.positive = 0;
handle.peak_gauss.display.negative = 0;
handle.peak_gauss.caxis = [-3 3];

handle.peak_consecutive.display.allresponse = 0;
handle.peak_consecutive.display.positive = 0;
handle.peak_consecutive.display.negative = 0;
handle.peak_consecutive.count_threshold = 3;
handle.peak_consecutive.caxis = [-3 3];

handle.corona.wt = 6;
handle.corona.ignore = [73 15];

data = EDGE_processing(handle);
