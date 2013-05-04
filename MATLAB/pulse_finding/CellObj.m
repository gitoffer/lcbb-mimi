classdef CellObj
	%--- CellObj ----------------------------------------------------------
    % Collects EDGE measurements for each cell, as well as the TRACK
	% and FITTED pulses found in that cell.
	%
	% PROPERTIES (private)
    %   embryoID
	%   cellID
	%   stackID
    %   
    %   area
    %   area_sm
    %   myosin_intensity_fuzzy
    %   myosin_sm
    %   centroid_x
    %   centroid_y
    %   identity_of_neighbors_all
    %   vertex_x
    %   vertex_y
    %
    %   dev_frame
    %   dev_time
    %
    % Properties (public)
    %   flag_fitted
    %   fit_colorized
    %   fit_bg
    %   fit_gausses
    %
    % Methods
	%	--- Constructor ---
	%		CellObj - use from embryo2cell
	%	--- Fit pulses ---
	%		fit_gaussians - returns updated CellObj array
	%			and FITTED array
	%	--- Edit fit/tracks ---
	%		addFit - add fit to a cell
	%		removeFit - remove a fit from a cell
	%		addTrack - add a track to a cell
	%		removeTrack - remove trackID from a cell's records
	%	--- Array set/access ---
	%		get_stackID - search by stackID
	%		get_fitID - search for cells containing fitID
	%		get_trackID - search for cells containing trackID
	%		get_embryoID_cellID - search using embryoID + cellID (useful
    %           coming from EDGE)
	%	--- Visualization/display ---
	%		visualize - plots myosin + area v. time
	%		movie - makes movie of cell
	%
	% See also: PULSE, FITTED, TRACK, EMBRYO2CELL
	%
	% xies@mit.edu April 2013.
    
    properties (SetAccess= private)
        
        % IDs
        embryoID % embryo index
        cellID	% cellID in EDGE
        stackID	% stackID in collated cell stack
        folder_name % EDGE folder name
        
        % measurements
        area		% area time series
        area_sm		% smoothed area
        centroid_x	% x-centroid of cell
        centroid_y	% y-centroid of cell
        identity_of_neighbors_all	% cell arrays of neighboring stackIDs
        myosin_intensity_fuzzy		% myosin intensity (fuzzy border)
        myosin_sm					% smoothed fuzzy myosin intensity
        vertex_x	% vertices, x-coordinates
        vertex_y	% vertices, y-coordinates
        
        % Time
        dev_time	% multiple-embryo-aligned, developmental time
        
    end % Private properties (can't be changed)
    
    properties
        % Fitting
        flag_fitted	% Flagged if not skipped in fitting
        fit_colorized % RGB colorization of multiple peaks, for colored movie display (see MAKE_PULSE_MOVIE)
        fit_bg		% Background fit
        fit_gausses	% Sum of all gaussians fitted
        fit_time	% The time-domain of fitted pulses
        residuals   % Residuals
        num_fits    % Number of pulses found
        fitID       % The fitIDs of FITTED found in this cell
        
        % Tracking
		flag_tracked % Flagged if tracked
        num_tracks  % number of tracks found in this cell
        trackID     % trackID of tracks found in cell
    end % Public properties - to do with track/fit
    methods
        
        function obj = CellObj(this_cell)
			% CellObj - Contructs object of CellObj class. Use from EDGE2CELL
            field_names = fieldnames(this_cell);
            for i = 1:numel(field_names)
                obj.(field_names{i}) = this_cell.(field_names{i});
            end
			obj.flag_tracked = 0;
            obj.num_tracks = 0;
        end % Constructor
        
        function [new_cells,fit] = fit_gaussians(cells,opts)
            %FIT_GAUSSIANS Fit multiple-Gaussians with a F-test stop
            
            num_embryos = max(unique([cells.embryoID]));
            num_cells = hist([cells.embryoID],1:num_embryos);
            
            if numel(opts) ~= num_embryos
                error('Each embryo must have an associated fitting option structure.');
            end
            
            [cells(1:sum(num_cells)).flag_fitted] = deal(0);
            num_frames = numel(cells(1).dev_time);
            
            fitID = 0; last_embryoID = cells(1).embryoID; fit = [];
            
            for stackID = 1:sum(num_cells)
                
                this_cell = cells(stackID);
                if this_cell.embryoID ~= last_embryoID, fitID = 0; end % reset fitID count
                
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
                
                % Reject curves without the requisite number of non-NaN
                % data points. Also reject if too many consecutive NaN
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
                    
                    % --- Get fitted curves, except for array of Gaussians ---
%                     curve = synthesize_gaussians(gauss_p(:,2:end),t); % Get gaussians/time
                    background = lsq_exponential(gauss_p(:,1),t); % Get background
                    P = plot_peak_color(gauss_p(:,2:end),t); % Get colorized fit
                    this_cell.fit_colorized = P; this_cell.fit_bg = background;
					this_cell.fit_time = t;
                    this_cell.residuals = residuals;
                    
                    % --- Get pulse info ---
                    this_cell.num_fits = size(gauss_p,2) - 1;
                    this_cell.fitID = [];
                    
					fit_gausses = nan( numel(t), max(size(gauss_p,2) - 1, 1) );
                    
                    for j = 2 : size(gauss_p,2)
                        
                        % Assign fitID
                        fitID = fitID + 1;
                        
                        embryo_fitID = fitID + this_cell.embryoID*1000;

                        fit = [fit Fitted(this_cell, gauss_p(:,j), embryo_fitID, opt)];
                        
                        % Construct Fitted object
                        this_cell.fitID = [this_cell.fitID embryo_fitID];
                        
						% Collect the cell-centric fitted curve for this peak
						fit_gausses(:,j - 1) = lsq_gauss1d(gauss_p(:,j),this_cell.fit_time);
                    end
                    
                this_cell.fit_gausses = fit_gausses;    
                else
                    this_cell.fit_colorized = NaN;
                    this_cell.fit_bg = NaN;
                    this_cell.fit_gausses = NaN;
                    this_cell.fit_time = NaN;
                    this_cell.residuals = NaN;
                    this_cell.num_fits = NaN;
                    this_cell.fitID = NaN;
                    this_cell.num_tracks = NaN;
                    this_cell.trackID = NaN;
                end
                new_cells(stackID) = this_cell;
                
                last_embryoID = this_cell.embryoID;
                
            end
            
        end % fit_gaussians
        
% ---------------------- Editing fit/tracks -------------------------------
        
        function cellobj = addFit(cellobj,fitID)
            %@CellObj.addFit Add a fitID to a cell
            cellobj.fitID = [cellobj.fitID fitID];
            cellobj.num_fits = cellobj.num_fits + 1;
        end % addFit
        
        function cellobj = removeFit(cellobj,fitID)
            %@CellObj.removeFit remove a fitID from a cell
            idx = find([cellobj.fitID] == fitID); % find removing index
            cellobj.fitID(idx) = []; % remove fitID 
            cellobj.fit_gausses(:,idx) = []; % remove Gaussian colorized peak
            cellobj.num_fits = cellobj.num_fits - 1;
        end % removeFit
        
        function cellobj = addTrack(cellobj,trackID)
            %@CellObj.addTrack Add a trackID to a cell
            cellobj.trackID = [ [cellobj.trackID] trackID];
            cellobj.num_tracks = cellobj.num_tracks + 1;
        end
        
        function cellobj = removeTrack(cellobj,trackID)
            %@CellObj.addTrack Add a trackID from a cell
            cellobj.trackID([cellobj.trackID] == trackID) = [];
            cellobj.num_tracks = cellobj.num_tracks - 1;
        end

% --------------------- Array set/access ----------------------------------
        
        function obj = get_stackID(obj_array, stackID)
            %@Cell.get_stackID Returns the obj from an array with the given
            % stackID
            obj = obj_array( ismember([ obj_array.stackID ],stackID ));
        end % get_stackID
        
        function obj = get_fitID(obj_array, fitID)
            %@Cell.get_fitID Returns the obj from an array with the given
            % fitID
            obj = obj_array([obj_array.fitID] == fitID);
        end % get_fitID
        
        function obj = get_trackID(obj_array, trackID)
            %@Cell.get_fitID Returns the obj from an array with the given
            % trackID
            obj = obj_array([obj_array.trackID] == trackID);
        end
        
        function obj = get_embryoID_cellID(obj_array,embryoID,cellID)
            obj = obj_array( ...
                [obj_array.embryoID] == embryoID | ...
                [obj_array.cellID] == cellID ...
                );
        end
%---------------------- Visualization/display -----------------------------
        function visualize(cells,ID,handle)
            %VISUALIZE_CELL Plots the raw area and myosin data for a given cell as well
            % as its fitted pulses, if applicable.
            %
            % USAGE: h = visualize_cell(cells,stackID)
            %
            % xies@mit.edu Feb 2013

            % Extract cell
            this_cell = cells(ID);

            nonan_frame = this_cell.dev_time;
            nonan_frame = ~isnan(nonan_frame);
            time = this_cell.dev_time( nonan_frame );

            if nargin < 3, handle = gca; end

            % Plot raw data: myosin + area
            [h,fig1,fig2] = plotyy(handle, time, this_cell.myosin_sm(nonan_frame), ...
                time, this_cell.area_sm(nonan_frame) );

            set(fig1,'Color','g'); set(fig2,'Color','k')

            % set x-axis limits
            set(h(2) , 'Xlim', [min(time) max(time)] );

            if this_cell.flag_fitted

                hold(handle,'on');
                
                plot(handle,this_cell.fit_time, this_cell.fit_gausses);
                plot(handle,this_cell.fit_time, this_cell.fit_bg, 'c-');
                %     plot(handle,this_cell.fit_time, this_cell.fit_curve, 'm-');
                
                hold(handle,'off');

                    title(handle,['EDGE #' num2str(this_cell.cellID)])

            end

            set(h(1),'Xlim',[min(time) max(time)]);

            % if nargout > 0, varargout{1} = h; end

        end % visualize
        
        function F = movie(cells,stackID,embryo_stack)
            % MOVIE - make a movie of the cell
            % USAGE: F = movie(cells,stackID,embryo_stack)
            % xies@mit.edu
            
            % Extract cell
            this_cell = cells.get_stackID(stackID);
            % Get its embryo
            this_embryo = embryo_stack(this_cell.embryoID);
            % Get IDs
            h.cellID = this_cell.cellID;
            h.input = this_embryo.input;
            
            % Get vertices
            h.vx = this_embryo.vertex_x;
            h.vy = this_embryo.vertex_y;
            
            h.border = 'on';
            h.frames2load = find(~isnan(this_cell.dev_time));
            
            h.channels = {'Membranes','Myosin'};
            
            if this_cell.flag_fitted
                h.measurement = nan(numel(h.frames2load),3);
                I = find( ismember(this_cell.fit_time, this_cell.dev_time) );
                h.measurement(I,:) = this_cell.fit_colorized;
            end
                
            F = make_cell_img(h);
            
        end % movie

    end
    
end
