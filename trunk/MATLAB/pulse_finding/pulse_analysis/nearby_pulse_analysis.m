%% Nearby pulse analysis

fitsOI = fits_wt;

%%

time_windows = 10:10:100; % seconds

fitsOI = fitsOI.find_near_fits(time_windows,neighborID);

%%

nearIDs = cat(1,fitsOI.nearIDs);

% Convert to number of pulses
num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs);

%% MC stackID

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};

window = 6;
Nboot = 200;

left = [-Inf -Inf 0 60 120 180]; right = [Inf 0 60 120 180 Inf];

%% Permute stackID

num_member = zeros(numel(left),num_clusters);

empirical(Nboot,numel(left)).num_near = [];
empirical(Nboot,numel(left)).origin_labels = [];
empirical(Nboot,numel(left)).target_labels = [];

random_cell(Nboot,numel(left)).num_near = [];
random_cell(Nboot,numel(left)).origin_labels = [];
random_cell(Nboot,numel(left)).target_labels = [];

random_pulse(Nboot,numel(left)).num_near = [];
random_pulse(Nboot,numel(left)).origin_labels = [];
random_pulse(Nboot,numel(left)).target_labels = [];

for j = 1:Nboot
    
    tic
    % make permutations
%     [fits_bs_cell,cells_bs_cell] = cells.bootstrap_stackID(fitsOI);
%     % get nearby pulses
%     fits_bs_cell = fits_bs_cell.find_near_fits(time_windows,neighborID);
%     
%     % randomize pulses
%     [fits_bs_fit,cells_bs_fit] = fitsOI.bootstrap_stackID(cells);
%     fits_bs_fit = fits_bs_fit.find_near_fits(time_windows(window),neighborID);
    
    num_bs_cell = zeros(num_clusters,num_clusters+1);
    num_bs_fit = zeros(num_clusters,num_clusters+1);
    num_neighbors = zeros(num_clusters,num_clusters+1);

    for k = 1:numel(left) % iterating through time-bins
        
        % filter by time criterion for averaging
        if j == 1
            filtered = fitsOI( ...
                [fitsOI.center] > left(k) & [fitsOI.center] <= right(k));
        end
        filtered_bs_cell = fits_bs_cell( ...
            [fits_bs_cell.center] > left(k) & [fits_bs_cell.center] <= right(k));
        filtered_bs_fit = fits_bs_fit( ...
            [fits_bs_fit.center] > left(k) & [fits_bs_fit.center] <= right(k));
        
        % breakdown neighbor by clusters
        for i = 1:num_clusters
            
            % get current cluster for empirical
            if j == 1
                this_cluster = filtered([filtered.cluster_label] == i);
                if ~isempty(this_cluster)
                    % tabulate
                    this_nearIDs = cat(1,this_cluster.nearIDs);
                    num_near = cellfun(@(x) numel(x(~isnan(x))), this_nearIDs);
                    num_near = num_near(:,6);
                    target_labels = ...
                        [fitsOI.get_fitID([this_nearIDs{:,window}]).cluster_label];
                    num_neighbors(i,:) = ([foo.cluster_label],1:6);
                    num_member(k,i) = numel(this_cluster);
                end
            end
            
            % get current cluster for simulated cells/pulses
            this_cluster_bs_cell = filtered_bs_cell([filtered_bs_cell.cluster_label] == i);
            this_cluster_bs_fit = filtered_bs_fit([filtered_bs_fit.cluster_label] == i);
                        
            if ~isempty(this_cluster_bs_cell)
                % random-cell
                nearIDs_cell = cat(1,this_cluster_bs_cell.nearIDs);
                foo = fits_bs_cell.get_fitID([nearIDs_cell{:,window}]);
                num_bs_cell(j,k,i,:) = hist([foo.cluster_label],1:6);
            end
            
            if ~isempty(this_cluster_bs_fit)
                % random-pulse
                nearIDs_fit = cat(1,this_cluster_bs_fit.nearIDs);
                foo = fits_bs_fit.get_fitID([nearIDs_fit{:,window}]);
                num_bs_fit(j,k,i,:) = hist([foo.cluster_label],1:6);
            end
            
        end
        if j == 1
            num_near{j,k} = num_neighbors;
        end
        num_near_cell{j,k} = num_bs_cell;
        num_near_fit{j,k} = num_bs_fit;
        
    end
    
    T = toc;
    display(['Done with ' num2str(j) ' in ' num2str(T) ' seconds.']);
    
end

save('~/Desktop/bootstrap_wt','num_member','num_neighbors','num_bs_cell','num_bs_fit');

%% Total neighbor number

N = zeros( numel(left), num_clusters );
for k = 1:numel(left)
    
    if k < 3, figure; end
    if k > 1, subplot(3,2,k-1); end
    
    foo = ( sum(num_neighbors(k,:,:),3) ...
        - nanmean(squeeze( sum(num_bs_cell(:,k,:,:),4) )) ) ...
        ./ nanstd(squeeze( sum(num_bs_cell(:,k,:,:),4) ));
    foo2 = ( sum(num_neighbors(k,:,:),3) ...
        - nanmean(squeeze( sum(num_bs_fit(:,k,:,:),4) )) ) ...
        ./ nanstd(squeeze( sum(num_bs_fit(:,k,:,:),4) ));
    
    % Z-score bargraph
    h = bar(1:5, ...
        cat(1, foo,foo2)' ,'LineStyle','None');
    set(h(1),'FaceColor','r');
    set(h(2),'FaceColor','g');
    
    if k < 3
        xlabel('Center cluster label')
        ylabel('Z score')
%         set(gca,'XTickLabel',entries);
    end
        title(['Number of neighbors ' ...
            num2str(window) '0s after, ' num2str(left(k)) ' < center < ' num2str(right(k))]);
    
end

%% Break down neighbor identity

for k = 1:numel(left)
    
    if k < 3, figure; end
    if k > 1, subplot(3,2,k-1); end
    
    foo = ( squeeze(num_neighbors(k,:,:)) ...
        - squeeze(nanmean(num_bs_fit(:,k,:,:))) ) ...
        ./squeeze(nanstd(num_bs_fit(:,k,:,:)));
    % iterate through all center labels
    bar(1:5,foo,'LineStyle','None');
    
    if k < 3
        ylabel('Z score')
%         set(gca,'XTickLabel',[entries,'N/A']);
    end
    
    title(['Number of neighbors ' ...
        num2str(window) '0s after, ' num2str(left(k)) ' < center < ' num2str(right(k))]);
    
end

