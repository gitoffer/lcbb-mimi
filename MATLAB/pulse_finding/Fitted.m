classdef Fitted
	%Fitted A fitted pulse as found by multiple-Gaussian fitting
	%
	% Methods
	%	Fitted - cosntructor, see @Cell.FIT_GAUSSIANS
	%	removeFit
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
        img_frames
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
        
        category
        manually_added
        bin
        
    end
    methods % Dynamic methods
        function obj = Fitted(this_fit)
            %Fitted Constructor - use from FIT_GAUSSIANS (array constructor)
			% USAGE: obj = FITTED(this_fit)
            if nargin > 0
                names = fieldnames(this_fit);
                for i = 1:numel(names)
                    [obj.(names{i})] = deal(this_fit.(names{i}));
                end
                obj.manually_added = 0;
            end
        end % constructor
        
% --------------------- Edit pulse ----------------------------------------
        
        function obj_array = add_fit(obj_array,new_fit)
            
            new_fit.fitID = max([obj_array.fitID]) + 1;
            new_fit = Fitted( new_fit );
            new_fit.manually_added = 1;
            
            if any(obj_array == new_fit)
                disp('Cannot create new fit: Fit already exists.');
                beep
                return
            end
            
            obj_array = [obj_array new_fit];
            
        end % add_fit
        
        function obj_array = removeFit(obj_array,fitID)
			%removeFit Removes a fit of a given fitID from an array
			% USAGE: obj_array = obj_array.removeFit(fitID)
            obj_array(obj_array.get_fitID(fitID)) = [];
        end % removeFit
        
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
                [~,max_idx] = max( fits(i).fit );
                
                left_len = max_idx - 1;
                
                m = nan(1, l + r + 1); % Make the padded vector
                m( (center_idx - left_len) : (center_idx - left_len + durations(i) - 1) ) = ...
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
        
        function pulses = resample_traces(pulses,name,dt,opt)
            %RESAMPLE_TRACES Uses INTERP1 to resample short traces
            %
            % [aligned_traces,aligned_time] = resample_traces(traces,embryoID,dt);
            %
            % xies@mit.edu Oct 2012
            
            traces = cat(1,pulses.(name));
            
            num_traces = size(traces,1);
            
            embryoIDs = [pulses.embryoID];
            if numel(embryoIDs) ~= num_traces
                error('The number of traces and the number of embryoID must be the same.');
            end
            
            aligned_dt = round(mean(dt)*100)/100;
            l = opt.left_margin; r = opt.right_margin;
            % w = floor(T/2);
            
            % aligned_traces = zeros([num_traces, l + r - 3]);
            aligned_t = (- l : r )*aligned_dt;
            
            % Resample using the SIGNAL_PROCESSING TOOLBOX
            for i = 1:num_traces
                pulses(i).(['corrected_' name]) = ...
                    interp1((-l:r)*dt(embryoIDs(i)),traces(i,:),(-(l-2):r-2)*aligned_dt);
                pulses(i).corrected_time = aligned_t(3:end-2);
            end
            
        end % resample_traces
        
        function fits = retrace(fits, cells, opts)
            % Re-do the sub-sequence tracing with different margins
            % specified in the new FIT_OPT
            
            for i = 1:numel(fits)
                
                this_fit = fits(i);
                this_cell = cells.get_stackID(this_fit.stackID);
                num_frames = numel(this_cell.dev_time);
                opt = opts(this_fit.embryoID);
                center_frame = findnearest( this_fit.center, this_cell.dev_time );
                
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
                end
                if pad_r > 1
                    fitted_y = [fitted_y, nan(1, (center_frame + opt.right_margin) - num_frames)];
                end
                
                fits = fits.set_fitID(this_fit.fitID, this_fit);
                
            end
            
        end %retrace
        
% --------------------- Comparator ----------------------------------------

        function equality = eq(fit1,fit2)
            % Equality comparator for FITTED
            % right now slow, expecting array in first argument
            if numel(fit1) > 1 && numel(fit2) > 1
                error('Cannot handle TWO array inputs.');
            end
%             names = setdiff(fieldnames(fit2),{'fitID','category'});
            equality = false(1,numel(fit1));
            for j = 1:numel(fit1)
                if fit1(j).stackID == fit2.stackID
                % can't use bsxfun because of un-uniform output
                    if numel(fit1(j).width_frames( ...
                            ismember(fit1(j).width_frames, fit2.width_frames))) > 2
                        equality(j) = 1;
                    end
                end
            end

        end %eq
        
% --------------------- Array operations ----------------------------------
        
		function fits = bin_fits(fits)
            %BIN_FITS Bin fits according to their amplitudes

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
%             sizes = [fits.size];
            
            [~,sortID] = sort( [fits.amplitude] , 2,'descend');
            fits = fits(sortID);
            
        end

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
            
        end
        
    end
 
    methods (Static)
        
    end
    
end
