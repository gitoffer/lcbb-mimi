%% Nearby pulse analysis

fitsOI = fits_wt;

%%

time_windows = 10:10:100; % seconds

fitsOI = fitsOI.find_near_fits(time_windows,neighborID);

%%

nearIDs = cat(1,fitsOI.nearIDs);

% Convert to number of pulses
num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs(:,6));

%% Permute cluster labels

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};
% N = zeros(num_clusters,num_clusters,3);
% neighb_bin = zeros(num_clusters,4);
num_member = zeros(1,num_clusters);
window = 6;

left = -Inf; right = Inf;
Nboot = 50;

num_neighbors = zeros(1,num_clusters);
num_bs = zeros(Nboot,num_clusters);
for j = 1:Nboot
    
    fits_bs = fitsOI;
    filtered = fitsOI( ...
        [fitsOI.center] > left & [fitsOI.center] < right);
    filtered_bs = filtered.bootstrap_cluster_label;
    filtered_bs = filtered_bs.find_near_fits(time_windows,neighborID);
    
    for i = 1:num_clusters
        
         this_cluster = filtered([filtered.cluster_label] == order(i));
        this_cluster_bs = filtered_bs([filtered_bs.cluster_label] == order(i));
        
        this_cluster = this_cluster( ...
            [this_cluster.center] > left & [this_cluster.center] < right);
        this_cluster_bs = this_cluster_bs( ...
            [this_cluster_bs.center] > left & [this_cluster_bs.center] < right);
        
        foo = cat(1,this_cluster.nearIDs);
        num_neighbors(i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
        num_member(i) = numel(this_cluster);
        
        foo = cat(1,this_cluster_bs.nearIDs);
        num_bs(j,i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
        
    end
    
    display(['Done with ' num2str(j)]);
    
end
% num_neighbors = sum(N,3);
bar(1:5,num_neighbors); hold on;
errorbar(1:5,nanmean(num_bs),nanstd(num_bs),'r-')
xlabel('Center cluster label')
ylabel('# of neighbors')
set(gca,'XTickLabel',entries);
title(['Number of neighbors ' ...
num2str(window) '0s after, ' num2str(left) ' center < ' num2str(right)])


%% MC stackID

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};
% N = zeros(num_clusters,num_clusters,3);
% neighb_bin = zeros(num_clusters,4);
num_member = zeros(1,num_clusters);
window = 3;

left = -Inf; right = Inf;
Nboot = 50;

num_neighbors = zeros(1,num_clusters);
num_bs = zeros(Nboot,num_clusters);

for j = 1:Nboot
    
    % permutations
    [fits_bs,cells_bs] = fitsOI.bootstrap_stackID(cells);
    
    filtered = fitsOI( ...
        [fitsOI.center] > left & [fitsOI.center] < right);
    
    filtered_bs = filtered_bs.find_near_fits(time_windows,neighborID);
    
    for i = 1:num_clusters
        
%         eval(['cluster' num2str(i) '_bs = fits_bs([fits_bs.cluster_label] == ' num2str(order(i)) ');']);
        
        this_cluster = filtered([filtered.cluster_label] == order(i));
        this_cluster_bs = filtered_bs([filtered_bs.cluster_label] == order(i));
        
        this_cluster = this_cluster( ...
            [this_cluster.center] > left & [this_cluster.center] < right);
        this_cluster_bs = this_cluster_bs( ...
            [this_cluster_bs.center] > left & [this_cluster_bs.center] < right);
        
        foo = cat(1,this_cluster.nearIDs);
        num_neighbors(i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
        num_member(i) = numel(this_cluster);
        
        foo = cat(1,this_cluster_bs.nearIDs);
        num_bs(j,i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
        
    end
    display(['Done with ' num2str(j)])
end

% num_neighbors = sum(N,3);
bar(1:5,num_neighbors); hold on;
errorbar(1:5,nanmean(num_bs),nanstd(num_bs),'r-')
xlabel('Center cluster label')
ylabel('# of neighbors')
set(gca,'XTickLabel',entries);
title(['Number of neighbors ' ...
num2str(window) '0s after, ' num2str(left) ' center < ' num2str(right)])
