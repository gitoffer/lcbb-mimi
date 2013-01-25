% Load clustering result file from GEDAS Studio

filename = '~/Desktop/Clustering results/corrected_area_norm_notail/kmeans_c5_pearson.txt';
% filename = '~/Desktop/Clustering results/corrected_area_norm_top/kmeans_top_c5_cosine.txt'

cluster_flatfile = importdata(filename);

cluster_order = cluster_flatfile(:,1);
cluster_labels = cluster_flatfile(:,2); cluster_labels = cluster_labels + 1;
% Write cluster_labels onto proper pulse
% num_peaks = size(cluster_order,1);
for i = 1:size(cluster_labels,1)
    pulse(cluster_order(i)).cluster_label = cluster_labels(i);
    cluster_labels_ordered(cluster_order(i)) = cluster_labels(i);
end

%% Colorize each cell_fit with the cluster_label
for i = 1:sum(num_cells)
    % Change
    cell_fits(i).cluster_labels = nan(1,input(IDs(i).which).T);
end
for i = 1:num_peaks
    cell_fits(pulse(i).cell).cluster_labels( ...
        nonans(master_time(pulse(i).embryo).frame(pulse(i).frame))) = ...
        ones(size(nonans(master_time(pulse(i).embryo).frame(pulse(i).frame)))) ... 
        *pulse(i).cluster_label;
end

%% Write CSV data for GEDAS Studio

mkdir('~/Desktop/Clustering results/corrected_area_norm_notail/');
filename = '~/Desktop/Clustering results/corrected_area_norm_notail.csv';
data2write = cat(2,(1:num_peaks)',corrected_area_norm);

csvwrite(filename,data2write);