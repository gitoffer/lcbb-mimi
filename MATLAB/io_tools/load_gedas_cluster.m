% Load clustering result file from GEDAS Studio

cluster_dir = '~/Desktop/Clustering results/corrected_area_norm_notail/c6_pearson/';
filename = [cluster_dir 'kmeans_c6_pearson.txt'];
% filename = '~/Desktop/Clustering results/corrected_area_norm_top/kmeans_top_c5_cosine.txt'

[cluster_order,cluster_labels,cluster_labels_ordered,pulse] = load_gedas_fun(filename,pulse);

[num_clusters,num_members,cluster_names] = get_cluster_numbers(cluster_labels);

%% Colorize each cell_fit with the cluster_label
for i = 1:sum(num_cells)
    % Change
    cell_fits(i).cluster_labels = nan(1,input(IDs(i).which).T);
end
for i = 1:num_peaks
    cell_fits(pulse(i).cell).cluster_labels( ...
        nonans(master_time(pulse(i).embryo).frame(pulse(i).frame(2:end-5)))) = ...
        ones(size(nonans(master_time(pulse(i).embryo).frame(pulse(i).frame(2:end-5))))) ... 
        *pulse(i).cluster_label;
end

%% Write CSV data for GEDAS Studio

mkdir('~/Desktop/Clustering results/corrected_area_norm_notail/');
filename = '~/Desktop/Clustering results/corrected_area_norm_notail.csv';
data2write = cat(2,(1:num_peaks)',corrected_area_norm);

% csvwrite(filename,data2write);