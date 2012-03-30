%Load data
folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements';
msmts2make = {'myosin','area','vertex-x','vertex-y', ...
    'neighbors','ellipse','centroid'};

m = load_edge_data(folder2load,msmts2make{:});
zslice = 2;

areas = extract_msmt_data(m,'area','on',zslice);
myosins = extract_msmt_data(m,'myosin intensity','on',zslice);
centroids_x = extract_msmt_data(m,'centroid-x','on',zslice);
centroids_y = extract_msmt_data(m,'centroid-y','on',zslice);
neighborID = extract_msmt_data(m,'identity of neighbors','off',zslice);
vertices_x = extract_msmt_data(m,'vertex-x','off',zslice);
vertices_y = extract_msmt_data(m,'vertex-y','off',zslice);
majors = extract_msmt_data(m,'major axis','on',zslice);
minors = extract_msmt_data(m,'minor axis','on',zslice);
orientations = extract_msmt_data(m,'orientation','on',zslice);
anisotropies = extract_msmt_data(m,'anisotropy-xy','on',zslice);
coronal_area = extract_msmt_data(m,'corona area','on',zslice);

[num_frames,num_z,num_cells] = size(areas);

%% Smooth some data

areas_sm = smooth2a(areas,1,0);
myosins_sm = smooth2a(squeeze(myosins),1,0);
coronal_area_sm = smooth2a(coronal_area,1,0);


areas_rate = -central_diff_multi(areas_sm,1,1);
myosins_rate = central_diff_multi(myosins_sm);