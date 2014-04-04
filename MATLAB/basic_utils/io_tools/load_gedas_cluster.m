% Load clustering result file from GEDAS Studio

name = 'c5_pearson';
cluster_dir = ['~/Desktop/Clustering results/corrected_area_norm_nonan/' name '/'];
filename = [cluster_dir 'kmeans_' name '.txt'];
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

mkdir('~/Desktop/Clustering results/corrected_area_norm_nonan/');
filename = '~/Desktop/Clustering results/corrected_area_norm_nonan.csv';
foo = corrected_area_norm;
nonanIDs = find(all(~isnan(foo),2));
foo(find(any(isnan(foo),2)),:) = NaN;
data2write = cat(2,(1:num_peaks)',foo);

csvwrite(filename,data2write);
