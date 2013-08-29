%% Nearby pulse analysis

fitsOI = fits;

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
Nboot = 1;

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

window = 6;
Nboot = 100;

left = [-Inf -Inf 0 60 120 180]; right = [Inf 0 60 120 180 Inf];

%%


num_member = zeros(numel(left),num_clusters);
num_neighbors = zeros(numel(left),num_clusters,num_clusters+1);
num_bs_cell = zeros(Nboot,numel(left),num_clusters,num_clusters+1);
num_bs_fit = zeros(Nboot,numel(left),num_clusters,num_clusters+1);

for j = 1:Nboot
    
    tic
    % make permutations
    [fits_bs_cell,cells_bs_cell] = cells.bootstrap_stackID(fitsOI);
    % get nearby pulses
    fits_bs_cell = fits_bs_cell.find_near_fits(time_windows,neighborID);
    
    % randomize pulses
    [fits_bs_fit,cells_bs_fit] = fitsOI.bootstrap_stackID(cells);
    fits_bs_fit = fits_bs_fit.find_near_fits(time_windows,neighborID);
    
    for k = 1:numel(left) % iterating through time-bins
        
        % filter by time criterion for averaging
        filtered = fitsOI( ...
            [fitsOI.center] > left(k) & [fitsOI.center] < right(k));
        filtered_bs_cell = fits_bs_cell( ...
            [fits_bs_cell.center] > left(k) & [fits_bs_cell.center] <= right(k));
        filtered_bs_fit = fits_bs_fit( ...
            [fits_bs_fit.center] > left(k) & [fits_bs_fit.center] <= right(k));
        
        % numbered clusters
        for i = 1:num_clusters
            
            % get current cluster
            this_cluster = filtered([filtered.cluster_label] == order(i));
            this_cluster_bs_cell = filtered_bs_cell([filtered_bs_cell.cluster_label] == order(i));
            this_cluster_bs_fit = filtered_bs_fit([filtered_bs_fit.cluster_label] == order(i));
            
            % empirical
            this_nearIDs = cat(1,this_cluster.nearIDs);
            foo = fitsOI.get_fitID([this_nearIDs{:,window}]);
            labels = [foo.cluster_label];
            num_neighbors(k,i,:) = hist(revorder(labels(labels > 0)),1:6);
            num_member(k,i) = numel(this_cluster);
            
            % random-cell
            nearIDs_cell = cat(1,this_cluster_bs_cell.nearIDs);            
            foo = fits_bs_cell.get_fitID([nearIDs_cell{:,window}]);
            labels = [foo.cluster_label];
            num_bs_cell(j,k,i,:) = hist(revorder(labels(labels > 0)),1:6);

            % random-pulse
            nearIDs_fit = cat(1,this_cluster_bs_fit.nearIDs);
            foo = fits_bs_fit.get_fitID([nearIDs_fit{:,window}]);
            labels = [foo.cluster_label];
            num_bs_fit(j,k,i,:) = hist(revorder(labels(labels > 0)),1:6);
            
        end
        
    end
    
    T = toc;
    display(['Done with ' num2str(j) ' in ' num2str(T) ' seconds.']);
    
end

%% Total neighbor number

N = zeros( numel(left), num_clusters );
for k = 1:numel(left)
    
    figure,
    
    foo = ( sum(num_neighbors(k,:,:),3) ...
        - nanmean(squeeze( sum(num_bs_cell(:,k,:,:),4) )) ) ...
        ./ nanstd(squeeze( sum(num_bs_cell(:,k,:,:),4) ));
    foo2 = ( sum(num_neighbors(k,:,:),3) ...
        - nanmean(squeeze( sum(num_bs_fit(:,k,:,:),4) )) ) ...
        ./ nanstd(squeeze( sum(num_bs_fit(:,k,:,:),4) ));
    
    % Z-score bargraph
    bar(1:5, ...
        cat(1, foo,foo2)' );

    xlabel('Center cluster label')
    ylabel('Difference from MC neighbor count (random-pulse), normalized by standard deviation')
    set(gca,'XTickLabel',entries);
    title(['Number of neighbors ' ...
        num2str(window) '0s after, ' num2str(left(k)) ' < center < ' num2str(right(k))]);
    
end

%% Break down neighbor identity

for k = 1
        
    figure,
    
    foo = ( squeeze(num_neighbors(k,:,:)) ...
        - squeeze(nanmean(num_bs_fit(:,k,:,:))) ) ...
        ./squeeze(nanstd(num_bs_fit(:,k,:,:)));
    % iterate through all center labels
    bar(1:5,foo);
    
    set(gca,'XTickLabel',[entries,'N/A']);
    
    title(['Number of neighbors ' ...
        num2str(window) '0s after, ' num2str(left(k)) ' < center < ' num2str(right(k))]);
    
end

