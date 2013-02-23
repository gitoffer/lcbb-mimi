function [fit,new_cells] = fit_gaussians(cells,opts)


num_embryos = max(unique([cells.embryoID]));
num_cells = hist([cells.embryoID],1:num_embryos);

if numel(opts) ~= num_embryos
    error('Each embryo must have an associated fitting option structure.');
end

[cells(1:sum(num_cells)).flag_fitted] = deal(0);
num_frames = numel(cells(1).dev_frame);

fitID = 0;

for stackID = 1:sum(num_cells)
    
    this_cell = cells(stackID);
    
    % Get relevant indices
    embryoID = this_cell.embryoID;
    % Get specific options
    opt = opts(embryoID);
    
    Y = this_cell.(opt.to_fit); % curve to be fit
    t = this_cell.dev_time;     % independent variable (domain)
    
    failed = 0;
    % Interpolate and trucate NaN
    try [y,shift,endI] = interp_and_truncate_nan(Y);
    catch err
        failed = 1; shift = 1; endI = numel(Y);
    end
    
    consec_nan = find_consecutive_logical( isnan(Y(shift:endI)) );
    
    % Reject curves without the requisite number of non-NAN data poitns
    if max(consec_nan) < opt.nan_consec_thresh && any(Y > 0) && ~failed && ...
            numel(Y(~isnan(Y))) > opt.nan_thresh
        
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
        curve = synthesize_gaussians(gauss_p(:,2:end),t); % Get gaussians/time
        background = lsq_exponential(gauss_p(:,1),t); % Get background
        P = plot_peak_color(gauss_p(:,2:end),t); % Get colorized fit
        this_cell.fit_colorized = P; this_cell.fit_bg = background;
        this_cell.fit_gaussians = curve; this_cell.fit_time = t;
        this_cell.fit_curve = curve + background;
        this_cell.residuals = residuals;
        
        % --- Get pulse info ---
        this_cell.num_pulses = size(gauss_p,2) - 1;
        this_cell.fitID = [];
        
        for j = 2 : size(gauss_p,2)
            
            % Assign fitID
            fitID = fitID + 1;
            this_fit.fitID = fitID;
            
            % Collect the relevant IDs
            this_fit.embryoID = embryoID;
            this_fit.stackID = stackID;
            this_fit.cellID = this_cell.cellID;
            
            % Collect the parameters
            amplitude = gauss_p(1,j); center = gauss_p(2,j); width = gauss_p(3,j);
            this_fit.amplitude = amplitude;
            this_fit.center = center; this_fit.width = width;
            
            dev_time = this_cell.dev_time;
            center_frame = findnearest(center,dev_time);
            
            % Get pulse margin-time frame
            [left_margin,pad_l] = max([ center_frame - opt.left_margin , 1]);
            [right_margin,pad_r] = min([ center_frame + opt.left_margin , num_frames]);
            this_fit.margin_frames = left_margin:right_margin;
            
            % Get pulse width-time frame
            left_width = max( center_frame - findnearest(width,cumsum(diff(t))) , 1);
            right_width = min( center_frame + findnearest(width,cumsum(diff(t))) , num_frames);
            this_fit.width_frames = left_width:right_width;
            
            % Get pulse time WRT image/dev_time
            this_fit.img_frames = this_cell.dev_frame(left_width:right_width);
            this_fit.dev_time = this_cell.dev_time(left_width:right_width);
            
            % Collect the pulse-centric fitted curves
            x = dev_time(left_margin:right_margin);
            fitted_y = synthesize_gaussians(gauss_p(:,j),x);
            this_fit.raw = Y(left_margin:right_margin);
            this_fit.fit = fitted_y;
            this_fit.aligned_time = x - center;
            
            % PAD the margin-time frame for plotting purposes
            if pad_l > 1
                fitted_y = [ensure_row(nan(1 - (center_frame - opt.left_margin), 1)), fitted_y];
                x = [ensure_row(nan(1 - (center_frame - opt.left_margin), 1)), x];
            end
            if pad_r > 1
                fitted_y = [fitted_y, nan(1, (center_frame + opt.right_margin) - num_frames)];
                x = [x, nan(1, (center_frame + opt.right_margin) - num_frames)];
            end
            this_fit.aligned_time_padded = x;
            this_fit.fit_padded = fitted_y;
            
            fit(fitID) = Fitted(this_fit);
            
            % Construct Fitted object
%             fit(fitID) = this_fit;
            this_cell.fitID = [this_cell.fitID fitID];
            
        end
        
    else
        this_cell.fit_colorized = NaN;
        this_cell.fit_bg = NaN;
        this_cell.fit_gaussians = NaN;
        this_cell.fit_time = NaN;
        this_cell.fit_curve = NaN;
        this_cell.residuals = NaN;
        this_cell.num_pulses = NaN;
        this_cell.fitID = NaN;
    end
    
    new_cells(stackID) = this_cell;

end