classdef Fitted
    %--- FITTEd -----------------------------------------------------------
	% A fitted pulse as found by multiple-Gaussian fitting
	%
	% Methods:
    % 
    % --- Constructor ---
	%	Fitted - INPUT: CellObj, parameter, fitID, and opt_struct
    % --- Edit fit array ---
	%	add_fit - tries to append a given new_fit onto an array. Fails if
	%   	the same pulse already exists in the array
	%	removeFit - given a fitID, remove it from the object stack
    %   cat - concatenate two Fitted arrays
    % --- Array access/set ---
    %   get_stackID - get all FITs with a certain stackID
    %   get_fitID - get the fit with the given fitID
    %   set_fitID - replace a fit in the array with a given fitID with a
    %       new_fit
    % --- Alignment ---
    %   aling_fits - align the measurement according to the maxima of fits
    %   assign_datafield - given a matrix, assign each vector to a fit
    %   resample_traces - re-sample all data in a given fit array so as to
    %      have the same framerate (INTERP1)
    %   retrace - re-do the sub-sequence selection
    % --- Comparator ---
    %   eq - right now will be equal if overlap of width_frame is > 3
    % --- Array operations ---
    %   sort - sort according to amplitude
    %   bin_fits - bin each embryo by amplitude
	%	find_near_fits - find fits near a 'central' fit given a time-window
    % --- Visualization ---
    %   plot_binned_fits
    %   plot_heatmap (sorted)
    %   movie
	% --- Export ---
	%   export (export given measurement to csv file)
    %
    % See also: PULSE, TRACK, CELLOBJ
    %
    % xies@mit.edu April 2013.
    
    properties (SetAccess = private)
        
        % Initialized with
        embryoID
        cellID
        stackID
        fitID
        amplitude
        center
        width
        margin_frames
        width_frames
        dev_time
        raw
        fit
        aligned_time
        aligned_time_padded
        fit_padded
        
        % Added later
        myosin
        myosin_rate
        area
        area_rate
        area_norm
        corrected_time
        corrected_myosin
        corrected_myosin_rate
        corrected_area
        corrected_area_rate
        corrected_area_norm
        
    end
    properties (SetAccess = public)
        
        category % one2one, added, missed, so forth
        manually_added
        bin % intra-embryo pulse strength bin

        time_windows % 
        nearIDs % fitIDs of 'nearby' fits, ordered w.r.t. time_windows
        
        cluster_label
        cluster_weight
        
    end
    methods % Dynamic methods
    
% --------------------- Constructor -----------------------------------------
    
        function this_fit = Fitted(cell,params,fitID,opt)
            %Fitted Constructor - use from FIT_GAUSSIANS (array constructor)
            % Will populate the pulse-centric fields, like the margins, and
            % aligned curves and time.
            % 
			% USAGE: fit = FITTED(cell,params,fitID)
            
            if nargin > 0
                
                % FitID
                this_fit.fitID = fitID;
                
                % Collect the relevant indices
                this_fit.embryoID = cell.embryoID;
                this_fit.cellID = cell.cellID;
                this_fit.stackID = cell.stackID;
                
                % Collect the parameters
                this_fit.amplitude = params(1);
                this_fit.center = params(2); this_fit.width = params(3);
                
                dev_time = cell.dev_time;
                num_frames = numel(dev_time);
                center_frame = findnearest(this_fit.center,dev_time);
                
                % Get pulse margin-time frame
                [left_margin,pad_l] = max([ center_frame - opt.left_margin , 1]);
                [right_margin,pad_r] = min([ center_frame + opt.right_margin , num_frames]);
                this_fit.margin_frames = left_margin:right_margin;
                
                % Get pulse width-time frame
                left_width = max( ...
                    center_frame - findnearest(this_fit.width,cumsum(diff(dev_time))) , 1);
                right_width = min( ...
                    center_frame + findnearest(this_fit.width,cumsum(diff(dev_time))) , num_frames);
                this_fit.width_frames = left_width:right_width;
                
                % Get pulse time WRT dev_time
                this_fit.dev_time = dev_time(left_width:right_width);
                
                % Collect the pulse-centric fitted curves
                x = dev_time( left_margin : right_margin );
                fitted_y = lsq_gauss1d( params , x );
                this_fit.raw = ...
                    cell.(opt.to_fit)( left_margin : right_margin );
                this_fit.fit = fitted_y;
                this_fit.aligned_time = x - this_fit.center;
                
                
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
                        
%                 names = fieldnames(this_fit);
%                 for i = 1:numel(names)
%                     [fit.(names{i})] = deal(this_fit.(names{i}));
%                 end
                this_fit.manually_added = 0;
                
            end
        end % constructor
        
% --------------------- Edit fit array -----------------------------------
        
        function [obj_array,errorflag] = add_fit(obj_array,new_fit)
            %ADD_FIT tries to append a new_fit to a FITS array. Fails if
            % any fit in the array is equal to the new_fit.
            %
            % See also: FITTED.eq
            errorflag = 0;
            if any(obj_array == new_fit)
                disp('Cannot create new fit: Fit already exists.');
                beep
                errorflag = 1;
                return
            end
            
            obj_array = [obj_array new_fit];
            
        end % add_fit
        
        function obj_array = removeFit(obj_array,fitID)
			%removeFit Removes a fit of a given fitID from an array
			% USAGE: obj_array = obj_array.removeFit(fitID)
            obj_array([obj_array.fitID] == fitID) = [];
        end % removeFit

        function fit_array = reindex_fitID( fit_array, new_embryoID )
			%reindex_fitID Given an fit-array of the same embryoID, and a
			% new_embryoID, re-index the fitIDs of the array with a new set
			% of identifiers beginning with the new_embryoID
			
            old_embryoID = fit_array(1).embryoID;
            if any( [fit_array.embryoID] ~= old_embryoID )
                error('Must input an array with the same original embryoID');
            end
            
            old_fitIDs = [fit_array.fitID];
            new_fitIDs = old_fitIDs;
            % re-index 'normal' fitIDs
            new_fitIDs(~[fit_array.manually_added]) = ...
                new_fitIDs(~[fit_array.manually_added]) ...
                + (new_embryoID - old_embryoID)*1000;
            % re-index 'manually fitted' fitIDs
            new_fitIDs([fit_array.manually_added]) = ...
                new_fitIDs([fit_array.manually_added]) ...
                + (new_embryoID - old_embryoID)*10000;
            
        end % reindex_fitID
        
% --------------------- Array access/set ----------------------------------
        
        function objs = get_stackID(obj_array,stackID)
            % Find the FIT(s) with the given stackID(s)
			% usage: objs = obj_array.get_stackID(stackID)
            objs = obj_array( ismember([ obj_array.stackID ], stackID) );
        end %get_stackID
        
        function objs = get_fitID(obj_array,fitID)
            % Find the FIT(s) with the given fitID(s)
			% USAGE: objs = obj_array.get_fitID(fitID)
            objs = obj_array( ismember([ obj_array.fitID ], fitID) );
        end %get_fitID
        
        function fits = set_fitID(fits,fitID, fit)
            fits( [fits.fitID] == fitID ) = fit;
        end %set_fitID
        
% --------------------- Alignment functions -------------------------------
        
        function [fits] = align_fits(fits,measurement,name,opt)
            %ALIGN_PEAKS Aligns the global maxima of a given array of
            %FITTED objects
            % Will return also a given measurement aligned according to the
            % maxima. Updates the FITTED structure.
            %
            % SYNOPSIS: [fits,time] = align_peaks(fitss,cells,opt);
            
            num_fits = numel(fits);
            durations = cellfun(@numel, {fits.margin_frames} );
            l = opt.left_margin; r = opt.right_margin;

            center_idx = l + 1;
            
            for i = 1:num_fits
                
                frames = fits(i).margin_frames;
                [max_val,max_idx] = max( fits(i).fit );
                if numel( fits(i).fit( fits(i).fit == max_val ) ) > 1
                    maxes = find( fits(i).fit == max_val );
                    theoretical_middle = ceil(max(durations)/2);
                    which = findnearest(maxes,theoretical_middle);
                    max_idx = maxes(which);
                end
                
                left_len = max_idx - 1;
                
                m = nan(1, l + r + 1); % Make the padded vector
                lb = center_idx - left_len;
                ub = min(center_idx - left_len + durations(i) - 1, max(durations) );
                m( lb: ub) = ...
                    measurement( fits(i).margin_frames, fits(i).stackID );

                fits(i).(name) = m;
                
            end
            
        end % align_fits
        
        function [fits] = assign_datafield(fits,data,name)
			%assign_datafield Assign a matrix into the fields of fitted objects
			% USAGE: fits = assign_datafield(fits,data,name)
            if size(data,1) ~= numel(fits)
                error('Data size must be the same as the number of FITTED objects.');
            end
            for i = 1:numel(fits)
                fits(i).(name) = data(i,:);
            end
        end % assign_datafield
        
        function fits = resample_traces(fits,name,dt,opt)
            %RESAMPLE_TRACES Uses INTERP1 to resample short traces
            %
            % [aligned_traces,aligned_time] = resample_traces(traces,embryoID,dt);
            %
            % xies@mit.edu Oct 2012
            
            % concatenate traces
            traces = cat(1,fits.(name));
            
            % get dimensions
            num_traces = size(traces,1);
            embryoIDs = [fits.embryoID];
            
            if numel(embryoIDs) ~= num_traces
                error('The number of traces and the number of embryoID must be the same.');
            end
            
            % find the aligned DT
            aligned_dt = round(mean(dt)*100)/100;
            l = opt.left_margin; r = opt.right_margin;
            % w = floor(T/2);
            
            % aligned_traces = zeros([num_traces, l + r - 3]);
            aligned_t = (- l : r )*aligned_dt;
            
            % Resample using the SIGNAL_PROCESSING TOOLBOX
            for i = 1:num_traces
                
                trace = traces(i,:);
                trace = trace( ~isnan(trace) );
                x = (-l:r)*dt( embryoIDs(i) );
                x = x( ~isnan(trace) );
                
                fits(i).(['corrected_' name]) = ...
                    interp1( x, trace, (-(l-2):r-2)*aligned_dt );
                
                fits(i).corrected_time = aligned_t(3:end-2);
            end
            
        end % resample_traces
        
        function fits = retrace(fits, cells, opts)
            % Re-do the sub-sequence tracing with different margins
            % specified in the new FIT_OPT
            
            for i = 1:numel(fits)
                
                this_fit = fits(i);
                
                this_cell = cells.get_stackID(this_fit.stackID);
                num_frames = numel(nonans(this_cell.dev_time));
                opt = opts(this_fit.embryoID);
                center_frame = findnearest( this_fit.center, this_cell.dev_time );
                % check for double-nearest
                if numel(center_frame) > 1
                    center_frame = center_frame(end);
                end
                
                % Get margin frame
                [left_margin,pad_l] = max( ...
                    [center_frame - opt.left_margin, 1] );
                [right_margin,pad_r] = min( ...
                    [center_frame + opt.right_margin, num_frames] );
                this_fit.margin_frames = left_margin:right_margin;
                
                % Collect the fit curve
                x = this_cell.dev_time( left_margin:right_margin );
                fitted_y = lsq_gauss1d( ...
                    [this_fit.amplitude, this_fit.center, this_fit.width], x);
                this_fit.raw = this_cell.(opt.to_fit)( left_margin: right_margin );
                this_fit.fit = fitted_y;
                this_fit.aligned_time = x - this_fit.center;
                
                % PAD
                if pad_l > 1
                    fitted_y = [ensure_row(nan(1 - (center_frame - opt.left_margin), 1)), fitted_y];
                    x = [ensure_row(nan(1 - (center_frame - opt.left_margin), 1)), x];
                end
                if pad_r > 1
                    fitted_y = [fitted_y, nan(1, (center_frame + opt.right_margin) - num_frames + 1)];
                    x = [x, nan(1, (center_frame + opt.right_margin) - num_frames)];
                end
                this_fit.aligned_time_padded = x - this_fit.center;
                fits = fits.set_fitID(this_fit.fitID, this_fit);

            end
            
        end %retrace
        
%        function fits = recenter
%        end
        
% --------------------- Comparator ----------------------------------------

        function equality = eq(fit1,fit2)
            % Equality comparator for FITTED
            % right now slow, expecting array in first argument and single object
			% in the second (fit2). Will return equal if the width_frame of two
			% fits have overlap > 3.
            if numel(fit1) > 1 && numel(fit2) > 1
                error('Cannot handle TWO array inputs.');
            end
%             names = setdiff(fieldnames(fit2),{'fitID','category'});
            equality = false(1,numel(fit1));
            for j = 1:numel(fit1)
                if fit1(j).stackID == fit2.stackID
                % can't use bsxfun because of un-uniform output
                    if numel(fit1(j).width_frames( ...
                            ismember(fit1(j).width_frames, fit2.width_frames))) > 3
                        equality(j) = 1;
                    end
                end
            end

        end %eq
        
% --------------------- Array operations ----------------------------------
        
		function fits = bin_fits(fits)
            %BIN_FITS Bin fits according to their amplitudes. Quartile binning.

            [fits.bin] = deal(NaN);
            
			embryoIDs = unique( [fits.embryoID] );

			for i = embryoIDs
				
                % Get fits in this embryo that are not manually curated
				fits_this_embryo = ...
                    fits( [fits.embryoID] == i & ~[fits.manually_added] );
				fitIDs_this_embryo = [ fits_this_embryo.fitID ];
                
                % Sort by amplitude
				amps = [ fits_this_embryo.amplitude ];
				[ sorted_amps, sortID ] = sort( amps, 2, 'descend' );

                % Get percentile cutoffs
				cutoffs = prctile( sorted_amps, [ 25 50 75 ] );
				sortedID = fitIDs_this_embryo( sortID );
				
                % Get fitIDs
				top = sortedID(1 : find( sorted_amps < cutoffs(3), 1) );
				top_middle = sortedID( find(sorted_amps < cutoffs(3),1) + 1 : ...
					find(sorted_amps < cutoffs(2), 1) );
				bottom_middle = sortedID( find(sorted_amps < cutoffs(2), 1) + 1 : ...
					find( sorted_amps < cutoffs(1), 1) );
				bottom = sortedID( find(sorted_amps < cutoffs(1), 1) + 1: end);

                % Assign bins
				[fits( ismember([fits.fitID],top ) ).bin] = deal(1);
                [fits( ismember([fits.fitID],top_middle ) ).bin] = deal(2);
                [fits( ismember([fits.fitID],bottom_middle ) ).bin] = deal(3);
                [fits( ismember([fits.fitID],bottom ) ).bin] = deal(4);

			end
			
        end %bin_fits
        
        function fits = sort(fits)
            %SORT fitted pulses by their amplitudes (descending order)
            
            [~,sortID] = sort( [fits.amplitude] , 2,'descend');
            fits = fits(sortID);
            
        end % sort
        
        function fits = find_near_fits(fits,time_windows,neighborID)
            %FIND_NEAR_FITS Find the number (and fitID) of each fitted
            % pulse within an range of time-windows and the first-order
            % neighbors, given array of fitted pulses. Results will
            % populate the fits object array.
            %
            % USAGE: fits = ...
            %           fits.find_near_fits(time_windows,neighborID)
            %
            % Note that neighborID returns original EDGE IDs (cellID) and
            % not stackIDs.
            %
            % xies@mit
            
            num_fits = numel(fits);
%             nearby_fits = cell(1,num_fits);
%             nearIDs = cell(1,num_fits);
            
            for i = 1:num_fits
                
                this_fit = fits(i);
                % Get fits in the same embryo
                same_embryo = fits( [fits.embryoID] == this_fit.embryoID );
                % Get the center frame of this pulse
                center_frame = fix( mean(this_fit.margin_frames) );
                % Get all neighboring cells
                neighbor_cells = neighborID{ center_frame , this_fit.stackID};
                
                fits(i).time_windows = time_windows;
                
                for j = 1:numel(neighbor_cells) % j - neighbor cell's stackID
                    
                    % Find all neighboring fits
                    neighbor_fits = same_embryo([same_embryo.cellID] == neighbor_cells(j));
                    
                    if ~isempty( neighbor_fits )
                        % Collect fits within window
                        
                        for k = 1:numel( time_windows )
                        
                            within_window = ...
                                abs([neighbor_fits.center] - this_fit.center) < time_windows(k) ...
                                & ~( neighbor_fits == this_fit );
                            if sum(within_window) > 0
                                nearby_fits = neighbor_fits(within_window);
                                %                             nearIDs{i} = [ neighbor_fits(within_window).fitID ];
                                fits(i).nearIDs(k) = [neighbor_fits.fitID];
                            end
                        end % loop over time window
                        
                    end
                    
                end % loop over neighbors
                
            end % loop over all fits
            
        end %find_near_fits

% --------------------- Visualization -------------------------------------
        
        function plot_binned_fits(fits)
            %Plot error-bar maps of the aligned myosin and aligned area
            %change for pulses of different bins
            
            if isempty(fits(1).bin), fits = fits.bin_fits; end
            
            % Extract the bins
            top = fits( [fits.bin] == 1);
            top_middle = fits( [fits.bin] == 2 );
            bottom_middle = fits( [fits.bin] == 3 );
            bottom = fits( [fits.bin] == 4 );
            
            % Get time vector
            x = fits(1).corrected_time;
            
            % Plot the myosins
            figure, hold on,
            shadedErrorBar( x, ...
                nanmean( cat(1, top.corrected_myosin ) ), ...
                nanstd( cat(1, top.corrected_myosin ) ), 'r-', 1);
            shadedErrorBar( x, ...
                nanmean( cat(1, top_middle.corrected_myosin) ), ...
                nanstd( cat(1, top_middle.corrected_myosin) ), 'b-', 1);
            shadedErrorBar( x, ...
                nanmean( cat(1, bottom_middle.corrected_myosin) ), ...
                nanstd( cat(1, bottom_middle.corrected_myosin) ), 'k-', 1);
            shadedErrorBar( x, ...
                nanmean( cat(1, bottom.corrected_myosin) ), ...
                nanstd( cat(1, bottom.corrected_myosin) ), 'g-', 1);
            hold off
            xlabel('Aligned time (sec)')
            ylabel('Myosin intensity (a.u.)')
            
            figure, hold on,
            shadedErrorBar( x, ...
                nanmean( cat(1, top.corrected_area_norm) ), ...
                nanstd( cat(1, top.corrected_area_norm) ), 'r-', 1);
            shadedErrorBar( x, ...
                nanmean( cat(1, top_middle.corrected_area_norm) ), ...
                nanstd( cat(1, top_middle.corrected_area_norm) ), 'b-', 1);
            shadedErrorBar( x, ...
                nanmean( cat(1, bottom_middle.corrected_area_norm) ), ...
                nanstd( cat(1, bottom_middle.corrected_area_norm) ), 'k-', 1);
            shadedErrorBar( x, ...
                nanmean( cat(1, bottom.corrected_area_norm) ), ...
                nanstd( cat(1, bottom.corrected_area_norm) ), 'g-', 1);
            hold off
            xlabel('Aligned time (sec)')
            ylabel('\Delta area (\mum^2)')
            
        end % plot_binned_fits
        
        function plot_heatmap(fits)
            
            fits = sort(fits);
            
            figure
            subplot(1,5,1)
            h = plot( numel(fits):-1:1 , [fits.amplitude] );
            set(h,'LineWidth',5);
            set(gca, 'CameraUpVector', [1 0 0] );
            set(gca, 'XLim', [1 numel(fits)] );
            set(gca, 'XTick', []);
            ylabel('Fitted amplitudes');
            
            subplot(1,5,2:3)
            [X,Y] = meshgrid( fits(1).corrected_time, numel(fits):-1:1);
            pcolor( X,Y, cat(1,fits.corrected_myosin) );
            shading flat; axis tight; colorbar;
            title('Aligned myosin')
            xlabel('Aligned time (sec)');
            
            subplot(1,5,4:5)
            pcolor( X,Y, cat(1,fits.corrected_area_norm) );
            shading flat; axis tight; colorbar;
            caxis( [-10 10] );
            title('Aligned area response');
            xlabel('Aligned time (sec)');
            
        end %plot_heatmap
        
        function varargout = movie(fits, fitID, embryo_stack, cells)
            % MOVIE - Wrapper for MAKE_CELL_IMG to make a movie of a single
            % fitted pulse.
            %
            % USAGE: fits.movie(fitID,cells,input,measurement);
            % xies@mit.edu
            
            % Extract this fit
            this_fit = fits.get_fitID(fitID);
            % Find its embryo
            this_embryo = embryo_stack( this_fit.embryoID );
            % The frames2load are the width-frames (1 sigma away)
            frames = this_fit.margin_frames;
            % Get vertices
            h.vx = this_embryo.vertex_x;
            h.vy = this_embryo.vertex_y;
            % Get IDs
            h.cellID = this_fit.cellID;
            h.input = this_embryo.input;
            % Get frames (no need to correct for t0, done in
            % MAKE_CELL_IMG)
            h.frames2load = frames;
            
            h.channels = {'Membranes','Myosin'};
            
            % Pad the curve
            this_cell = cells.get_stackID( this_fit.stackID );
            h.measurement = nan(size( this_cell.dev_time ));
            h.measurement( this_fit.margin_frames ) = this_fit.fit;
            
            % Turn on segmentation border
            h.border = 'on';
            
            figure
            F = make_cell_img(h);
            
            if nargout, varargout{1} = F; end
            
        end %movie
        
% ------------------------- Export ----------------------------------------

        function export_fits(fits,filepath,fieldname)
            %Exports the given FIELDNAME of a FIT array to CSV file
            %
            % USAGE: export_fits(fits,filepath,fieldname);
                        
            fitIDs = [fits.fitID]';
            manual_flag = [fits.manually_added]';
            
            mat2write = cat(2,fitIDs,manual_flag);
            
            data = cat(1,fits.(fieldname));
            
            mat2write = cat(2,mat2write,data);
            
            header = [NaN NaN 1:numel(fits(1).(fieldname))];
            
            mat2write = cat(1,header,mat2write);
            
            csvwrite([filepath '/fits_' fieldname,'.csv'] , mat2write);
            
        end %export_fits
        
    end % Dynamic methods
 
    methods (Static)
        
    end
    
end