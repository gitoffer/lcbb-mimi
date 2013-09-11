%% Nearby pulse analysis

fitsOI = fits_twist;

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

random_cell(Nboot).num_near = [];
random_cell(Nboot).origin_labels = [];
random_cell(Nboot).target_labels = [];
random_cell(Nboot).centers = [];

random_pulse(Nboot).num_near = [];
random_pulse(Nboot).origin_labels = [];
random_pulse(Nboot).target_labels = [];
random_pulse(Nboot).centers = [];

for j = 1:Nboot
    
    tic
    % make permutations
    [fits_bs_cell,cells_bs_cell] = cells.bootstrap_stackID(fitsOI);
    % get nearby pulses
    fits_bs_cell = fits_bs_cell.find_near_fits(time_windows,neighborID);
    
    % randomize pulses
    [fits_bs_fit,cells_bs_fit] = fitsOI.bootstrap_stackID(cells);
    fits_bs_fit = fits_bs_fit.find_near_fits(time_windows,neighborID);
    
    % get current cluster for empirical (only once)
    if j == 1
        
        this_nearIDs = cat(1,fitsOI.nearIDs);
        % calculate num-neighbors for each pulse
        num_near = cellfun(@(x) numel(x(~isnan(x))), this_nearIDs);
        % origin labels
        labels = [fitsOI.cluster_label]';
        % get all target labels
        target_labels = ...
            cellfun(@(x) [fitsOI.get_fitID(x).cluster_label], ...
            this_nearIDs,'UniformOutput',0);
        % get centers
        centers = [fitsOI.center];
        
        empirical.num_near = num_near;
        empirical.origin_labels = labels;
        empirical.target_labels = target_labels;
        empirical.centers = centers;
        
    end
    
    % random-cell
    if ~isempty(fits_bs_cell)
        
        nearIDs_cell = cat(1,fits_bs_cell.nearIDs);
        % tabluate num-neighbors for each pulse
        num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs_cell);
        % get origin labels
        labels = [fits_bs_cell.cluster_label]';
        % break down all target labels
        target_labels = ...
            cellfun(@(x) [fits_bs_cell.get_fitID(x).cluster_label], ...
            nearIDs_cell,'UniformOutput',0);
        centers = [fits_bs_cell.center];
        
        random_cell(j).num_near = num_near;
        random_cell(j).origin_labels = labels;
        random_cell(j).target_labels = target_labels;
        random_cell(j).centers = centers;
        
    end
    
    % random-fit
    if ~isempty(fits_bs_fit)
        
        nearIDs_fit = cat(1,fits_bs_fit.nearIDs);
        % tabluate num-neighbors for each pulse
        num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs_fit);
        % get origin labels
        labels = [fits_bs_fit.cluster_label]';
        % break down all target labels
        target_labels = ...
            cellfun(@(x) [fits_bs_fit.get_fitID(x).cluster_label], ...
            nearIDs_fit,'UniformOutput',0);
        centers = [fits_bs_fit.center];
        
        random_pulse(j).num_near = num_near;
        random_pulse(j).origin_labels = labels;
        random_pulse(j).target_labels = target_labels;
        random_pulse(j).centers = centers;
    end
    
    T = toc;
    display(['Done with ' num2str(j) ' in ' num2str(T) ' seconds.']);
    
end

save(['~/Desktop/bootstrap_twistclc_N' num2str(Nboot)], ...
    'empirical','random_cell','random_pulse');


%% Select correct timing

K = 3;

num_emp = empirical.num_near;
num_cell = cat(3,random_cell.num_near);
num_pulse = cat(3,random_pulse.num_near);

labels_emp = empirical.origin_labels;
labels_cell = random_cell(1).origin_labels;
labels_pulse = random_cell(1).origin_labels;

% filter
filter = @(x) (x.centers > left(K) & x.centers <= right(K));

num_emp = num_emp( filter(empirical), :);
labels_emp = labels_emp( filter(empirical) );

num_cell = num_cell( filter(random_cell(1)), :, :);
labels_cell = labels_cell( filter(random_cell(1)) );

num_pulse = num_pulse( filter(random_pulse(1)), :, :);
labels_pulse = labels_pulse( filter(random_pulse(1)) );

%% Distribution of means

for i = 1:5
    
	this_count_cell = squeeze( num_cell( labels_cell == i,6,:) );
    this_count_pulse = squeeze( num_pulse( labels_pulse == i,6,:) );
    this_count_emp = num_emp( labels_emp == i, 6);
    
    mean_of_cell = mean(this_count_cell,1);
    mean_of_pulse = mean(this_count_pulse,1);
    mean_of_emp = mean(this_count_emp);
    
    [Nmean_pulse,bins] = hist(mean_of_pulse,30);
    [Nmean_cell,bins] = hist(mean_of_cell,bins);
    
    figure(1)
    h(i) = subplot(5,1,i);
    bar(bins, cat(1,Nmean_cell,Nmean_pulse)');
    vline(mean_of_emp);
        
    title(entries{i})
    
    if i == 1
        xlabel('Average number of neighbors')
        ylabel('Frequency')
        legend('Random-cell','Random-pulse','Empirical');
    end
    
    ksstat = zeros(1,Nboot);
    for j = 1:Nboot
        [H,~,ksstat(j)] = kstest2( this_count_pulse(:,j), this_count_emp, 0.05,'larger');
    end
    
    figure(2)
    subplot(5,1,i);
    hist(ksstat,50);
    
    figure(3)
    bins = 0:0.1:10;
    subplot(5,1,i);
    plot_cdf( this_count_emp,bins );
    hold on
    plot_cdf( this_count_cell(:), bins,'r-');
    plot_cdf( this_count_pulse(:), bins,'g-');
    
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

