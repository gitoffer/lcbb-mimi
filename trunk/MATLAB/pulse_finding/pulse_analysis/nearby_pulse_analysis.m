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

empirical(1,numel(left)).num_near = [];
empirical(1,numel(left)).origin_labels = [];
empirical(1,numel(left)).target_labels = [];

random_cell(Nboot,numel(left)).num_near = [];
random_cell(Nboot,numel(left)).origin_labels = [];
random_cell(Nboot,numel(left)).target_labels = [];

random_pulse(Nboot,numel(left)).num_near = [];
random_pulse(Nboot,numel(left)).origin_labels = [];
random_pulse(Nboot,numel(left)).target_labels = [];

for j = 1:Nboot
    
    tic
    % make permutations
    [fits_bs_cell,cells_bs_cell] = cells.bootstrap_stackID(fitsOI);
    % get nearby pulses
    fits_bs_cell = fits_bs_cell.find_near_fits(time_windows,neighborID);
    
    % randomize pulses
    [fits_bs_fit,cells_bs_fit] = fitsOI.bootstrap_stackID(cells);
    fits_bs_fit = fits_bs_fit.find_near_fits(time_windows,neighborID);

    keyboard
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
        
        % get current cluster for empirical (only once)
        if j == 1
            if ~isempty(filtered)
                this_nearIDs = cat(1,filtered.nearIDs);
                % calculate num-neighbors for each pulse
                num_near = cellfun(@(x) numel(x(~isnan(x))), this_nearIDs);
                % origin labels
                labels = [filtered.cluster_label]';
                % get all target labels
                target_labels = ...
                    cellfun(@(x) [fitsOI.get_fitID(x).cluster_label], ...
                    this_nearIDs,'UniformOutput',0);
                
                empirical(k).num_near = num_near;
                empirical(k).origin_labels = labels;
                empirical(k).target_labels = target_labels;
            end
        end
        
        % random-cell
        if ~isempty(this_cluster_bs_cell)
            nearIDs_cell = cat(1,filtered_bs_cell.nearIDs);
            % tabluate num-neighbors for each pulse
            num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs_cell);
            % get origin labels
            labels = [filtered_bs_cell.cluster_label]';
            % break down all target labels
            target_labels = ...
                cellfun(@(x) [fitsOI.get_fitID(x).cluster_label], ...
                nearIDs_cell,'UniformOutput',0);
            
            random_cell(j,k).num_near = num_near;
            random_cell(j,k).origin_labels = labels;
            random_cell(j,k).target_labels = target_labels;
        end
        keyboard
        
        % random-fit
        if ~isempty(this_cluster_bs_fit)
            nearIDs_fit = cat(1,filtered_bs_fit.nearIDs);
            % tabluate num-neighbors for each pulse
            num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs_fit);
            % get origin labels
            labels = [filtered_bs_fit.cluster_label]';
            % break down all target labels
            target_labels = ...
                cellfun(@(x) [fitsOI.get_fitID(x).cluster_label], ...
                nearIDs_fit,'UniformOutput',0);
            
            random_pulse(j,k).num_near = num_near;
            random_pulse(j,k).origin_labels = labels;
            random_pulse(j,k).target_labels = target_labels;
        end
        
    end
    
    T = toc;
    display(['Done with ' num2str(j) ' in ' num2str(T) ' seconds.']);
    
end

save(['~/Desktop/bootstrap_wt_N' num2str(Nboot)], ...
    'empirical','random_cell','random_fit');

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

