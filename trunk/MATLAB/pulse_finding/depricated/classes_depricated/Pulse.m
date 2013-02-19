classdef Pulse
    %PULSE A signelPulse fitted from a CellObj's time-series.
    properties
        trackID
        pulseID
        category
    end
    properties (SetAccess = private)
        params
        IDs
        developmental_timeframe
        aligned_time
        padded_aligned_time
    end
    methods
        function pulse = Pulse(cellobj,gauss_p,fit_opts,pulse_index)
            % Assign a pulse index
            pulse.pulseID = pulse_index;
            % Get basic info about the cell
            pulse.IDs.embryoID = cellobj.IDs.embryoID;
            pulse.IDs.cellID = cellobj.IDs.cellID;
            pulse.IDs.stackID = cellobj.IDs.stackID;
            
            % Collect the parameters of the gaussian
            amplitude = gauss_p(1); center = gauss_p(2); width = gauss_p(3);
            % Collect into Pulse object
            pulse.params.amplitude = amplitude;
            pulse.params.center = center;
            pulse.params.width = width;
            
            % Get both the developmental time as well as the fitted time
            time = cellobj.developmental_timeframe.time;
            num_frames = numel(time);
%             t = cellobj.fit.time; num_frames = numel(t);
            
            % Find center frame of pulse
            center_frame = findnearest(center,time);
            pulse.developmental_timeframe.center_frame = center_frame;
            
            % Get the pre-set subsequence margins
            left_margin = fit_opts.left_margin; right_margin = fit_opts.right_margin;
            
            % Find the truncation shift between dev. time and fit time
%             shift = findnearest(t(1),time) - 1;
            % Find the left and right margins (pre-set)
%             left_frame = max( shift + center_frame - left_margin, 1);
%             right_frame = min( shift + center_frame + right_margin, num_frames);
            left_frame = max( center_frame - left_margin, 1 );
            right_frame = min( center_frame + right_margin, num_frames );
            % Find the left and right margins according to 1 sigma on each side
            sigma_left = max( center_frame - findnearest(width,cumsum( diff(time) )), 1);
            sigma_right = min( center_frame + findnearest(width,cumsum( diff(time) )), num_frames);
%             sigma_left = max( shift + center_frame ...
%                 - findnearest(width,cumsum( diff(t) ) ), 1);
%             sigma_right = min( shift + center_frame ...
%                 + findnearest(width,cumsum( diff(t) ) ), num_frames);
            
            % Collect the two sets of subsequence frames
            pulse.developmental_timeframe.margin_frames = left_frame:right_frame;
            pulse.developmental_timeframe.sigma_frames = sigma_left:sigma_right;
            
            % Get aligned subsequences of the curve
            x = time(left_frame:right_frame);
            fitted_y = lsq_gauss1d(gauss_p,x);
            y = cellobj.data.(fit_opts.to_fit);
            % Pulse fitted curves
            pulse.aligned_time.fit = fitted_y;
            % Pulse raw curve
            pulse.aligned_time.raw = y(left_frame:right_frame);
            % Pulse aligned sub-time
            pulse.aligned_time.time = x - center;
            
            % PAD the small subsequences to standardized size
            if center_frame - left_frame < 1
                fitted_y = [ nan( 1 - (shift + center_frame - left_frame), 1); ...
                    fitted_y];
                x = [ nan( 1 - (shift + center_frame) - left_frame, 1); x];
            end
            if center_frame + right_frame < num_frames
                fitted_y = [fitted_y; ...
                    nan( center_frame + right_frame - num_frames,1) ];
                x = [ nan( 1 - center_frame - left_frame, 1); x];
            end
            % Collect the padded aligned times/curves
            pulse.padded_aligned_time.fit_padded = fitted_y;
            pulse.padded_aligned_time.time = x;
            
        end % Constructor
        function pulse = match_pulse2track(pulse,trackID)
            pulse.trackID = trackID;
        end % match_pulse2track
        function pulse = categorize_pulse(category)
            pulse.category = category;
        end % categorize_pulse
    end
end