%% Nearby pulse analysis

fitsOI = fits_wt;

%%

time_windows = 10:10:100; % seconds

fitsOI = fitsOI.find_near_fits(time_windows,neighborID);

%%

nearIDs = cat(1,fitsOI.nearIDs);

% Convert to number of pulses
num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs);

%% Permute cluster labels

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};

window = 3;

left = [-Inf -Inf 0 60 120 180]; right = [Inf 0 60 120 180 Inf];
Nboot = 100;

num_member = zeros(numel(left),num_clusters);
num_neighbors = zeros(numel(left),num_clusters);
num_bs = zeros(Nboot,numel(left),num_clusters);

% iterate over filters
for k = 1:numel(left)
    
    for j = 1:Nboot
        
        tic
        
        fits_bs = fitsOI;
        % permute filtered
        fits_bs = fits_bs.bootstrap_cluster_label;
        fits_bs = fits_bs.find_near_fits(time_windows,neighborID);
        
        % filter
        filtered = fitsOI( ...
            [fitsOI.center] > left(k) & [fitsOI.center] <= right(k));
        filtered_bs = fits_bs( ...
            [fits_bs.center] > left(k) & [fits_bs.center] <= right(k));
        
        % avg from different behaviors
        for i = 1:num_clusters
            
            this_cluster = filtered([filtered.cluster_label] == order(i));
            this_cluster_bs = filtered_bs([filtered_bs.cluster_label] == order(i));
            
            foo = cat(1,this_cluster.nearIDs);
            if ~isempty(foo)
                num_neighbors(k,i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
                num_member(k,i) = numel(this_cluster);
            end
            
            foo = cat(1,this_cluster_bs.nearIDs);
            if ~isempty(foo)
                num_bs(j,k,i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
            end
            
        end
        
        T = toc;
        display(['Done with ' num2str(j) ' in ' num2str(T) ' seconds.']);
    
    end
    
    
    figure
    % num_neighbors = sum(N,3);
    bar(1:5,num_neighbors(k,:)); hold on;
    errorbar(1:5, ...
        nanmean(squeeze( num_bs(:,k,:) )), ...
        nanstd(squeeze( num_bs(:,k,:) )),'r-')
    xlabel('Center cluster label')
    ylabel('# of neighbors')
    set(gca,'XTickLabel',entries);
    hold off
    title(['Number of neighbors ' ...
        num2str(window) '0s after, ' num2str(left(k)) ' < center < ' num2str(right(k))]);
    
end

%% MC stackID

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};

window = 3;
Nboot = 100;

left = [-Inf -Inf 0 60 120 180]; right = [Inf 0 60 120 180 Inf];

num_member = zeros(numel(left),num_clusters);
num_neighbors = zeros(numel(left),num_clusters);
num_bs = zeros(Nboot,numel(left),num_clusters);

for j = 1:Nboot
    
    tic
    % make permutations
    [fits_bs,cells_bs] = fitsOI.bootstrap_stackID(cells);
    % get nearby pulses
    fits_bs = fits_bs.find_near_fits(time_windows,neighborID);
    
    for k = 1:numel(left) % iterating through time-bins
        
        % filter by time criterion for averaging
        filtered = fitsOI( ...
            [fitsOI.center] > left(k) & [fitsOI.center] < right(k));
        filtered_bs = fits_bs( ...
            [fits_bs.center] > left(k) & [fits_bs.center] < right(k));
        
        for i = 1:num_clusters
            
            % get current cluster
            this_cluster = filtered([filtered.cluster_label] == order(i));
            this_cluster_bs = filtered_bs([filtered_bs.cluster_label] == order(i));
            
            foo = cat(1,this_cluster.nearIDs);
            num_neighbors(k,i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
            num_member(k,i) = numel(this_cluster);
            
            foo = cat(1,this_cluster_bs.nearIDs);
            num_bs(j,k,i) = numel( fitsOI.get_fitID( [foo{:,window}] ) );
            
        end
        
    end
    
    T = toc;
    
    display(['Done with ' num2str(j) ' in ' num2str(T) ' seconds.']);
    
end

for k = 1:numel(left)
    
    figure,
    % num_neighbors = sum(N,3);
    bar(1:5,num_neighbors(k,:)); hold on;
    errorbar(1:5, ...
        nanmean(squeeze( num_bs(:,k,:) )), ...
        nanstd(squeeze( num_bs(:,k,:) )),'r-')
    xlabel('Center cluster label')
    ylabel('# of neighbors')
    set(gca,'XTickLabel',entries);
    title(['Number of neighbors ' ...
        num2str(window) '0s after, ' num2str(left(k)) ' < center < ' num2str(right(k))]);
    hold off;
    
end


