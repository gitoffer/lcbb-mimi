function MC = monte_carlo_pulse_location(fits,cells,neighborID,opt)
%MONTE_CARLO_PULSE_LOCATION Generate spatially random pulse patterns
% 
% USAGE: MC = monte_carlo_pulse_location(fits,cells,cx,cy,neighborID,opt)
%
% INPUT: fits - pulses
% 		 cells - cells
%		 neighborID - neighborhood of each cell
%		 opt - options for MC analysis
%		 	.Nboot - number of iterations
%			.time_windows - windows in time to check
%			.neighbor_def - neighborhood defintion
%			.savepath
%
% OUTPUT: MC
%
% xies@mit.edu Oct 2013

% parse input options structure
Nboot = opt.Nboot;
time_windows = opt.timewindows;
neighbor_def = opt.neighbor_def;

% get cell info
cx = cat(2,cells.centroid_x); cy = cat(2,cells.centroid_y);

% preallocate variables
random_cell(Nboot).num_near = [];
random_cell(Nboot).origin_labels = [];
random_cell(Nboot).target_labels = [];
random_cell(Nboot).centers = [];
random_cell(Nboot).correlation = [];

random_pulse(Nboot).num_near = [];
random_pulse(Nboot).origin_labels = [];
random_pulse(Nboot).target_labels = [];
random_pulse(Nboot).centers = [];
random_pulse(Nboot).correlation = [];

for j = 1:Nboot
    
    tic
    % make permutations of cell location
    [fits_bs_cell,~] = cells.bootstrap_stackID(fits);
    % get nearby pulses
	fits_bs_cell = fits_bs_cell.find_near_fits(time_windows,neighborID,neighbor_def);
    
    % make permutations of pulse location
    [fits_bs_fit,~] = fits.bootstrap_stackID(cells);
    fits_bs_fit = fits_bs_fit.find_near_fits(time_windows,neighborID,neighbor_def);
    
    % get current cluster for empirical (only once)
    if j == 1
        
        this_nearIDs = cat(1,fits.nearIDs);
        % calculate num-neighbors for each pulse
        num_near = cellfun(@(x) numel(x(~isnan(x))), this_nearIDs);
        % origin labels
        labels = [fits.cluster_label]';
        % get all target labels
        target_labels = ...
            cellfun(@(x) [fits.get_fitID(x).cluster_label], ...
            this_nearIDs,'UniformOutput',0);
        % get centers
        centers = [fits.center];
        
        empirical.num_near = num_near;
        empirical.origin_labels = labels;
        empirical.target_labels = target_labels;
        empirical.centers = centers;
        
    end
    
    % random-cell
    if ~isempty(fits_bs_cell)
        
        nearIDs_cell = cat(1,fits_bs_cell.nearIDs);
        % tabulate num-neighbors for each pulse
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
        % tabulate num-neighbors for each pulse
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
    
    % Compute correlation function
    random_cell(j).correlation = spatial_correlation(cx,cy,fits_bs_cell,30);
    random_pulse(j).correlation = spatial_correlation(cx,cy,fits_bs_fit,30);
    
    T = toc;
    display(['Done with ' num2str(j) ' in ' num2str(T) ' seconds.']);
    
end

MC.empirical = empirical;
MC.random_cell = random_cell;
MC.random_pulse = random_pulse;

MC.neighbor_def = neighbor_def;
MC.time_windows = time_windows;

save(opt.savepath,'MC');

end
