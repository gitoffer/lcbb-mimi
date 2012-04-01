%Load data
folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements';
msmts2make = {'myosin','area','vertex-x','vertex-y', ...
    'neighbors','ellipse','centroid'};

EDGEstack = load_edge_data(folder2load,msmts2make{:});
zslice = 2;

areas = extract_msmt_data(EDGEstack,'area','on',zslice);
myosins = extract_msmt_data(EDGEstack,'myosin intensity','on',zslice);
centroids_x = extract_msmt_data(EDGEstack,'centroid-x','on',zslice);
centroids_y = extract_msmt_data(EDGEstack,'centroid-y','on',zslice);
neighborID = extract_msmt_data(EDGEstack,'identity of neighbors','off',zslice);
vertices_x = extract_msmt_data(EDGEstack,'vertex-x','off',zslice);
vertices_y = extract_msmt_data(EDGEstack,'vertex-y','off',zslice);
majors = extract_msmt_data(EDGEstack,'major axis','on',zslice);
minors = extract_msmt_data(EDGEstack,'minor axis','on',zslice);
orientations = extract_msmt_data(EDGEstack,'orientation','on',zslice);
anisotropies = extract_msmt_data(EDGEstack,'anisotropy-xy','on',zslice);
coronal_area = extract_msmt_data(EDGEstack,'corona area','on',zslice);

[num_frames,num_z,num_cells] = size(areas);

%% Smooth some data
transition_frame = 60;

areas_sm = smooth2a(areas,1,0);
myosins_sm = smooth2a(squeeze(myosins),1,0);
coronal_area_sm = smooth2a(coronal_area,1,0);
orientations_sm = smooth2a(orientations,1,0);

areas_rate = -central_diff_multi(areas_sEDGEstack,1,1);
myosins_rate = central_diff_multi(myosins_sm);
anisotropies_rate = central_diff_multi(anisotropies);