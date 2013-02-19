function [pulse,new_cells] = fit_gaussians(cells,opts)


num_embryos = max(unique([cells.embryoID]));
num_cells = hist([cells.embryoID],1:num_embryos);

if numel(opts) ~= num_embryos
    error('Each embryo must have an associated fitting option structure.');
end

[cells(1:sum(num_cells)).flag_fitted] = deal(0);
num_frames = numel(cells(1).dev_frame);

pulseID = 0;

for stackID = 1:sum(num_cells)
    
    this_cell = cells(stackID);
    
    % Get relevant indices
    embryoID = this_cell.embryoID;
    % Get specific options
    opt = opts(embryoID);
    
    Y = this_cell.(opt.to_fit); % curve to be fit
    t = this_cell.dev_time;     % independent variable (domain)
    
    % Reject curves without the requisite number of non-NAN data poitns
    if numel(Y(~isnan(Y))) > opt.nan_thresh && any(Y > 0)
        
        % Interpolate and trucate NaN
        [y,shift] = interp_and_truncate_nan(Y);
        t = t( shift : shift + numel(y) - 1);
        
        % Establish the lower constraints
        lb = [0; t(1); opt.sigma_lb];
        % Establish the upper constraints
        ub = [nanmax(y); t(end) - opt.end_tol; opt.sigma_ub];
        
        % Perform multiple-fitting
        [gauss_p, residuals] = iterative_gaussian_fit( ...
            y,t,opt.alpha,lb,ub,opt.bg);
        
        % Turn on the 'fitted' flag
        this_cell.flag_fitted = 1;
        
        % --- Get fitted curves ---
        this_fit = synthesize_gaussians(gauss_p(:,2:end),t); % Get gaussians/time
        background = lsq_exponential(gauss_p(:,1),t); % Get background
        P = plot_peak_color(gauss_p(:,2:end),t); % Get colorized fit
        this_cell.fit_colorized = P; this_cell.fit_bg = background;
        this_cell.fit_gaussians = this_fit; this_cell.fit_time = t;
        this_cell.fit_curve = this_fit + background;
        this_cell.residuals = residuals;
        
        % --- Get pulse info ---
        this_cell.num_pulses = size(gauss_p,2) - 1;
        this_cell.pulseID = [];
        
        for j = 2 : size(gauss_p,2)
            
            % Assign pulseID
            pulseID = pulseID + 1;
            this_pulse.pulseID = pulseID;
            
            % Collect the relevant IDs
            this_pulse.embryoID = embryoID;
            this_pulse.stackID = stackID;
            this_pulse.cellID = this_cell.cellID;
            
            % Collect the parameters
            amplitude = gauss_p(1,j); center = gauss_p(2,j); width = gauss_p(3,j);
            this_pulse.amplitude = amplitude;
            this_pulse.center = center; this_pulse.width = width;
            
            dev_time = this_cell.dev_time;
            center_frame = findnearest(center,dev_time);
%             this_pulse.center_frame = center_frame;
            % Get pulse margin-time frame
            [left_margin,pad_l] = max([ center_frame - opt.left_margin , 1]);
            [right_margin,pad_r] = min([ center_frame + opt.left_margin , num_frames]);
            this_pulse.margin_frames = left_margin:right_margin;
            % Get pulse width-time frame
            left_width = max( center_frame - findnearest(width,cumsum(diff(t))) , 1);
            right_width = min( center_frame + findnearest(width,cumsum(diff(t))) , num_frames);
            this_pulse.width_frames = left_width:right_width;
            
            % Collect the pulse-centric fitted curves
            x = dev_time(left_margin:right_margin);
            fitted_y = synthesize_gaussians(gauss_p(:,j),x);
            this_pulse.raw = Y(left_margin:right_margin);
            this_pulse.fit = fitted_y;
            this_pulse.aligned_time = x - center;
            
            % PAD the margin-time frame for plotting purposes
            if pad_l > 1
                fitted_y = [nan(1 - (center_frame - opt.left_margin), 1), fitted_y];
                x = [nan(1 - (center_frame - opt.left_margin), 1), x];
            end
            if pad_r > 1
                fitted_y = [fitted_y, nan(1, (center_frame + opt.right_margin) - num_frames)];
                x = [x, nan(1, (center_frame + opt.right_margin) - num_frames)];
            end
            this_pulse.aligned_time_padded = x;
            this_pulse.fit_padded = fitted_y;
            
            pulse(pulseID) = this_pulse;
            this_cell.pulseID = [this_cell.pulseID pulseID];
            
        end
        
    else
        this_cell.fit_colorized = NaN;
        this_cell.fit_bg = NaN;
        this_cell.fit_gaussians = NaN;
        this_cell.fit_time = NaN;
        this_cell.fit_curve = NaN;
        this_cell.residuals = NaN;
        this_cell.num_pulses = NaN;
        this_cell.pulseID = NaN;
    end
    
    new_cells(stackID) = this_cell;

end