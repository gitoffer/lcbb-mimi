%CELLOBJ Contains the 
classdef CellObj
    properties
        pulseID
        trackID
        num_pulses
        pulse_flags
    end
    properties (SetAccess = protected)
        IDs
        data
        developmental_timeframe
        fit
    end
    methods
        function cellobj = CellObj(embryoID,stackID,cellID)
            % CELLOBJ Constructor - for initializing the object
            cellobj.IDs.embryoID = embryoID;
            cellobj.IDs.stackID = stackID;
            cellobj.IDs.cellID = cellID;
            cellobj.pulse_flags.fitted_flag = 0;
            cellobj.pulse_flags.tracked_flag = 0;
        end % constructor
        
        function cellobj = input_celldata(cellobj,myosin,area_sm,master_time)
            % CELLOBJ.INPUT_CELLDATA Set the relevant data into the cell.
            % USAGE: cellobj = input_celldata(myosin,area_sm,mater_time)
            cellobj.data.area_sm = area_sm;
            cellobj.data.myosin = myosin;
            cellobj.developmental_timeframe.time = ...
                master_time(cellobj.IDs.embryoID).aligned_time;
            cellobj.developmental_timeframe.padded_frames = ...
                master_time(cellobj.IDs.embryoID).frame;
        end % input_celldata
        
        function [cellobj,pulses] = fit_gaussian_peaks(cellobj,fit_opts,pulse_index)
            % FIT_GAUSSIAN_PEAKS Fit multiple Gaussian peaks to the cell's myosin
            % data with a F-stop criterion
            %
            % USAGE: cellobj = set.fit_gaussians cellobj, fit_opts
            
            % Check object validity
            if ~is_valid_celldata(cellobj), error('CellObj not initialized correctly.'); end
            
            pulses = [];
            t = cellobj.developmental_timeframe.time;
            y = cellobj.data.(fit_opts.to_fit);
            
            % Only proceed if there are enough
            if numel( y (~isnan(y)) ) > fit_opts.nan_thresh && any(y > 0)
                
                % Interpolate
                [y,f0] = interp_and_truncate_nan(y);
                t = t(f0 : f0+numel(y) - 1);
                
                % Establish the lower bounds of the constraints
                lb = [0; t(1); fit_opts.sigma_lb];
                ub = [nanmax(y); t(end) - fit_opts.end_tol; fit_opts.sigma_ub];
                
                % Perform iterative fitting
                [gauss_p,res] = iterative_gaussian_fit( ...
                    y,t,fit_opts.alpha,lb,ub,fit_opts.bg);
                
                % Get the time (first non-nan frame to last)
                cellobj.fit.time = t;
                cellobj.fit.residuals = res;
                % Get the residual and fitted background model
                cellobj.fit.background = lsq_exponential(gauss_p(:,1),t);
                
                % Check that there are pulses fit beyond the background model
                if size(gauss_p,2) > 1
                    % Get the colorized pulses
                    P = plot_peak_color(gauss_p(:,2:end),t);
                    cellobj.fit.colorized = P;
                    % Get the signal curve
                    cellobj.fit.signal = synthesize_gaussians(gauss_p(:,2:end),t);
                    % Get the number of peaks
                    cellobj.num_pulses = size(gauss_p,2)-1;
                else
                    % If no pulses were fit, move on
                    cellobj.fit.colorized = NaN;
                    cellobj.fit.signal_curve = NaN;
                    cellobj.num_pulses = 0;
                    return
                end
                
                % Initialize Pulse objects
                for i = 2:cellobj.num_pulses + 1
                    pulses = [pulses ...
                        Pulse(cellobj,gauss_p(:,i),fit_opts,pulse_index + i - 1)];
                    cellobj.pulseID = [cellobj.pulseID pulse_index + i - 1];
                end
            end
        end % fit_gaussian_peaks
    end
    methods (Access = private)
        % Private methods: Includes internal tests
        function continue_flag = is_valid_celldata(cellobj)
            if any([isempty(cellobj.data) isempty(cellobj.IDs)])
                continue_flag = 0;
            else
                continue_flag = 1;
            end
        end
    end
end