%% Nearby pulse analysis


%%

time_windows = 10:10:100; % seconds

fits_wt = fits_wt.find_near_fits(time_windows,neighborID);


%%

nearIDs = cat(1,fits_wt.nearIDs);

% Convert to number of pulses
num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs);

%%

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};
% N = zeros(num_clusters,num_clusters,3);
% neighb_bin = zeros(num_clusters,4);
num_member = zeros(1,num_clusters);

left = -Inf; right = Inf;
Nboot = 1000;

clear num_bs
for j = 1:Nboot
    
    % permutations
    fits_bs = fits_wt;
    
    
    filtered = fits( ...
        [fits.center] > left & [fits.center] < right);
    filtered_bs = filtered;
    labels = cat(1,filtered.cluster_label);
    labels = labels( randperm(numel(filtered)) );
    for i = 1:numel(filtered)
        filtered_bs(i).cluster_label = labels(i);
    end
    
    for i = 1:num_clusters
        
%         eval(['cluster' num2str(i) '_bs = fits_bs([fits_bs.cluster_label] == ' num2str(order(i)) ');']);
        
        this_cluster = filtered([filtered.cluster_label] == order(i));
        this_cluster_bs = filtered_bs([filtered_bs.cluster_label] == order(i));
        
        
        this_cluster = this_cluster( ...
            [this_cluster.center] > left & [this_cluster.center] < right);
        this_cluster_bs = this_cluster_bs( ...
            [this_cluster_bs.center] > left & [this_cluster_bs.center] < right);
        
        foo = cat(1,this_cluster.nearIDs);
        num_neighbors(i) = numel( fits_wt.get_fitID( [foo{:,6}] ) );
        num_member(i) = numel(this_cluster);
        
        foo = cat(1,this_cluster_bs.nearIDs);
        num_bs(j,i) = numel( fits_wt.get_fitID( [foo{:,6}] ) );
        
    end
end

% num_neighbors = sum(N,3);
bar(1:5,num_neighbors); hold on;
errorbar(1:5,nanmean(num_bs),nanstd(num_bs),'r-')
xlabel('Center cluster label')
ylabel('Pulse count')
set(gca,'XTickLabel',entries);
title('Number of neighbors 30s after, 0 < center < 60')
