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

		% Cell structure
		cell
        
    end
    properties (SetAccess = public)
        
        category
        manually_added
        
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
        function obj_array = removeFit(obj_array,fitID)
			%removeFit Removes a fit of a given fitID from an array
			% USAGE: obj_array = obj_array.removeFit(fitID)
            obj_array(obj_array.get_fitID(fitID)) = [];
        end
        
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
                pulses(i).corrected_time = aligned_t;
            end
            
        end % resample_traces
        
        
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

        end
% --------------------- Array operations ----------------------------------

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
            
        end
        
		function binned_array = bin(fits)

			embryoIDs = unique( [fits.embryoID] );
			binned_array = cell(1,4);
			binned_array{1} = []; binned_array{2} = []; binned_array{3} = []; binned_array{4} = [];

			for i = embryoIDs
				
				fits_this_embryo = fits( [fits.embryoID] == i);
				fitIDs_this_embryo = [ fits_this_embryo.fitID ];

				amps = [ fits_this_embryo.amplitude ];
				[ sorted_amps, sortID ] = sort( amps, 2, 'descend' );

				cutoffs = prctile( sorted_amps, [ 25 50 75 ] );
				sortedID = fitIDs_this_embryo( sortID );
				
				top = sortedID(1 : find( sorted_amps < cutoffs(3), 1) );
				top_middle = sortedID( find(sorted_amps < cutoffs(3),1) + 1 : ...
					find(sorted_amps < cutoffs(2), 1) );
				bottom_middle = sortedID( find(sorted_amps < cutoffs(2), 1) + 1 : ...
					find( sorted_amps < cutoffs(1), 1) );
				bottom = sortedID( find(sorted_amps < cutoffs(1), 1) + 1: end);

				binned_array{1} = [ binned_array{1} fits.get_fitID(top) ];
				binned_array{2} = [ binned_array{2} fits.get_fitID(top_middle) ];
				binned_array{3} = [ binned_array{3} fits.get_fitID(bottom_middle) ];
				binned_array{4} = [ binned_array{4} fits.get_fitID(bottom) ];

			end
			
		end
    end
 
    methods (Static)
        
    end
    
end
