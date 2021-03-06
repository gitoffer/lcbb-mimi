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
    %   centroid_x
    %   centroid_y
    %   identity_of_neighbors_all
    %   vertex_x
    %   vertex_y
    %   anisotropy_xy
    %   anisotropy
    %   myosin_intensity_fuzzy
    %   myosin_sm
    %
    %   dev_frame
    %   dev_time
    %
    % Properties (public)
    %   flag_fitted
    %   fit_colorized % RGB colorization of multiple peaks, for colored movie display (see MAKE_PULSE_MOVIE)
    %   fit_bg		% Background fit
    %   fit_gausses	% Sum of all gaussians fitted
    %   fit_time	% The time-domain of fitted pulses
    %   raw         % Raw curve
    %   residuals   % Residuals
    %   jacobian    % Jacobian
    %   params      % Keep track of pulse parameters
    %   num_fits    % Number of pulses found
    %   fitID       % The fitIDs of FITTED found in this cell
    %   opt         % fit_opts
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
    %       get_embryoID - only return embryos of given embryoID
	%		get_embryoID_cellID - search using embryoID + cellID (useful
    %           coming from EDGE)
    %       adjust_center - adjust dev_time to reflect new reference time
    %       get_nearby - get cells nearby within a given radius
	%	--- Visualization/display ---
	%		make_mask - returns a binary BW image of the cell
	%		visualize - plots myosin + area v. time
	%		movie - makes movie of cell
    %   --- Analysis ---
    %       get_pulsing_trajectories
    %       get_pulsing_transition_matrix
    %       get_pulsing_transition_graph
    %       get_neighbor_angle
    %       bootstrap_stackID
    %       make_binary_sequence
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
        myosin_intensity % unfuzzy
        myosin_intensity_fuzzy		% myosin intensity (fuzzy border)
        myosin_sm					% smoothed fuzzy myosin intensity
        vertex_x	% vertices, x-coordinates
        vertex_y	% vertices, y-coordinates
        anisotropy  % anisotropy (shape)
        anisotropy_xy % anisotropy (projection)
        
        % Time
        dev_time	% multiple-embryo-aligned, developmental time
        
    end % Private properties (can't be changed)
    
    properties
        
        % Fitting parameters / statistics
        flag_fitted	% Flagged if not skipped in fitting
        fit_colorized % RGB colorization of multiple peaks, for colored movie display (see MAKE_PULSE_MOVIE)
        fit_bg		% Background fit
        fit_gausses	% Sum of all gaussians fitted
        fit_time	% The time-domain of fitted pulses
        raw         % Raw curve
        residuals   % Residuals
        jacobian    % Jacobian
        params      % Keep track of pulse parameters
        num_fits    % Number of pulses found
        fitID       % The fitIDs of FITTED found in this cell
        opt         % fit_opts
        
        % Tracking
		flag_tracked % Flagged if tracked
        num_tracks  % number of tracks found in this cell
        trackID     % trackID of tracks found in cell
        
    end % Public properties - to do with track/fit
    
    methods
        
        function obj = CellObj(this_cell)
			% CellObj - Contructs object of CellObj class. Use from EMBRYO2CELL
            field_names = fieldnames(this_cell);
            for i = 1:numel(field_names)
                obj.(field_names{i}) = this_cell.(field_names{i});
            end
			obj.flag_tracked = 0;
            obj.num_tracks = 0;
        end % Constructor
        
        function obj = edit_field(obj,name,value)
            obj.(name) = value;
        end
        
        function [new_cells,fit] = fit_gaussians(cells,opts)
            %FIT_GAUSSIANS Fit multiple-Gaussians with a F-test stop
            % Uses LSQCURVEFIT
            % Might try 
            
            num_embryos = numel(unique([cells.embryoID]));
            num_cells = hist([cells.embryoID],1:num_embryos);
            
            if numel(opts) ~= num_embryos
                error('Each embryo must have an associated fitting option structure.');
            end
            
            [cells(1:sum(num_cells)).flag_fitted] = deal(0);
            num_frames = numel(cells(1).dev_time);
            
            fitID = 0; last_embryoID = cells(1).embryoID; fit = [];
            
            for i = 1:sum(num_cells)
                
                this_cell = cells(i);
				stackID = this_cell.stackID;
                if this_cell.embryoID ~= last_embryoID, fitID = 0; end % reset fitID count
                
                % Get relevant indices
                embryoID = this_cell.embryoID;
                % Get specific options
                opt = opts(1);
                
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
                    [gauss_p, residuals, J] = iterative_gaussian_fit( ...
                        y,t,opt.alpha,lb,ub,opt.bg);
                    
                    % Turn on the 'fitted' flag
                    this_cell.flag_fitted = 1;
                    this_cell.opt = opt;
                    
                    % --- Get fitted curves, except for array of Gaussians ---
%                     curve = synthesize_gaussians(gauss_p(:,2:end),t); % Get gaussians/time
                    background = lsq_exponential(gauss_p(:,1),t); % Get background
                    P = plot_peak_color(gauss_p(:,2:end),t); % Get colorized fit
                    this_cell.fit_colorized = P; this_cell.fit_bg = background;
					this_cell.fit_time = t;
                    this_cell.residuals = residuals;
                    this_cell.jacobian = J;
                    this_cell.params = gauss_p;
                    this_cell.raw = y;
                    
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
                else % This cell will NOT be fitted
                    this_cell.fit_colorized = NaN;
                    this_cell.fit_bg = NaN;
                    this_cell.fit_gausses = NaN;
                    this_cell.fit_time = NaN;
                    this_cell.residuals = NaN;
                    this_cell.jacobian = NaN;
                    this_cell.num_fits = NaN;
                    this_cell.fitID = NaN;
                    this_cell.num_tracks = NaN;
                    this_cell.trackID = NaN;
                    this_cell.params = NaN;
                    this_cell.opt = NaN;
                end
                new_cells(i) = this_cell;
                
                last_embryoID = this_cell.embryoID;
                
                display(['Done with cell #', num2str(stackID)])
                
            end
            
        end % fit_gaussians
        
% ---------------------- Editing fit/tracks -------------------------------
        
        function cellobj = addFit(cellobj,fit)
            %@CellObj.addFit Add a fitID to a cell
            cellobj.fitID = [cellobj.fitID fit.fitID];
            cellobj.num_fits = cellobj.num_fits + 1;
            % update gauss curves
			cellobj.fit_gausses = ...
				cat(2,cellobj.fit_gausses,...
                lsq_gauss1d([fit.amplitude;fit.center;fit.width],cellobj.fit_time)');
            % add new params
            cellobj.params = cat(2,cellobj.params,...
                [fit.amplitude;fit.center;fit.width]);
            params = cellobj.params;
            t = cellobj.fit_time;
            % recompute residuals
            cellobj.residuals = cellobj.raw ...
                - synthesize_gaussians_withbg(params,t);
            P = plot_peak_color(params(:,2:end),t);
            cellobj.fit_colorized = P;
        end % addFit
        
        function cellobj = removeFit(cellobj,fitID)
            %@CellObj.removeFit remove a fitID from a cell
            idx = find([cellobj.fitID] == fitID); % find removing index
            cellobj.fitID(idx) = []; % remove fitID 
            cellobj.fit_gausses(:,idx) = []; % remove Gaussian colorized peak
            cellobj.num_fits = cellobj.num_fits - 1;
            % update parameter list (remove)
            cellobj.params(:,idx+1) = [];
            
            params = cellobj.params;
            t = cellobj.fit_time;
            % update residuals
            cellobj.residuals = cellobj.raw - ...
                synthesize_gaussians_withbg(params,t);
            % update colorized curves
            P = plot_peak_color(params(:,2:end),t); % Get colorized fit
            cellobj.fit_colorized = P;
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
            obj = obj_array(...
                cellfun(@(x) (any(x == fitID)),{obj_array.fitID}) );
        end % get_fitID
        
        function obj = get_trackID(obj_array, trackID)
            %@Cell.get_fitID Returns the obj from an array with the given
            % trackID
            obj = obj_array([obj_array.trackID] == trackID);
        end % get_trackID
        
        function obj = get_embryoID(obj_array,embryoID)
            obj = obj_array(ismember([obj_array.embryoID],embryoID));
        end % get_embryoID
        
        function obj = get_embryoID_cellID(obj_array,embryoID,cellID)
            obj = obj_array( ...
                [obj_array.embryoID] == embryoID & ...
                [obj_array.cellID] == cellID ...
                );
        end % get_embryoID_cellID
        
        function cells = adjust_centers(cells, old_tref, new_tref, dt)
            %ADJUST_CENTERS Recalculate dev_time according to 
            % Properties that will be adjusted:
            %   dev_time
            
            % Only one embryo
            if numel(unique([cells.embryoID])) > 1
                error('Cells from only one embryo please.');
            end
            
            for i = 1:numel(cells)
                this_cell = cells(i);
                this_cell.fit_time = this_cell.fit_time - ...
                    (new_tref - old_tref)*dt;
                this_cell.dev_time = this_cell.dev_time - ...
                    (new_tref - old_tref)*dt;
                cells(i) = this_cell;
            end
        end
        
        function obj = get_curated(obj_array)
            obj = obj_array([obj_array.flag_tracked] == 1 & ...
                [obj_array.flag_fitted] == 1);
        end
        
        function nearby_cells = get_nearby(obj_array,stackID,radius,reference_frame)
            %@CellObj.GET_NEARBY Returns cells within radius r of a given
            % cell.
            %
            % SYNOPSIS: nearby_cells = cells.get_nearby(stackID,radius,ref_frame)
            %
            % INPUT: stackID - the central cell
            %        radius - the radius cutoff
            %        ref_frame - the reference frame in the movie to use
            %
            % OUTPUT: nearby_cells
            % xies@mit Feb 2014
            
            central_cell = obj_array.get_stackID(stackID);
            % Find all cells in the same embryo that's not the central cell
            same_embryo = obj_array.get_embryoID( central_cell.embryoID);
            same_embryo = same_embryo([same_embryo.stackID] ~= central_cell.stackID);
            
            cx = [same_embryo.centroid_x]; cx = cx(reference_frame,:);
            cy = [same_embryo.centroid_y]; cy = cy(reference_frame,:);
            
            d = sqrt( ...
                (cx - central_cell.centroid_x(reference_frame)).^2 ...
                + (cy - central_cell.centroid_y(reference_frame)).^2);
            
            nearby_cells = same_embryo( d <= radius );
        
        end
        
%---------------------- Visualization/display -----------------------------

		function mask = make_mask(obj_array, frames, input)
			%@CellObj.MAKE_MASK Make a BW mask of CellObjs using poly2mask.
			% 
			% SYNOPSIS: mask = cells.make_mask(frames,input)
			%
			% INPUT:	cellobj - a array of cellobjs
			%			frames - frames of interest
			% 			input - input information (see LOAD_EDGE_SCRIPT)
			% OUTPUT: 	mask - binary mask of size [X,Y,numel(frames)]
			%
			% See also: draw_measurement_on_cells, draw_measurement_on_cells_patch
			%
			% xies@mit August 2013

            num_cells = numel(obj_array);
            num_frames = numel(frames);
            
            % if input.um_per_px not supplied, use 1
            if ~isfield('input','um_per_px')
                um_per_px = 1;
            else
                um_per_px = input.um_per_px;
            end
            
            X = input.X; Y = input.Y;
            mask = zeros(Y,X,num_frames);
            
            for i = 1:num_cells
                vx = obj_array(i).vertex_x; vy = obj_array(i).vertex_y;
                % etract frames of interest
                vx = vx(frames,:); vy = vy(frames,:);
                for t = 1:num_frames
                    x = vx{t}/um_per_px; y = vy{t}/um_per_px;
                    if all(~isnan(x))
                        mask(:,:,t) = mask(:,:,t) + ...
                            poly2mask(x,y,Y,X);
                    end
                end
            end
            mask = logical(mask);
            
        end % make_mask
        
        function [x,y] = make_polygon(obj_array,t,input,filename)
            %@CellObj.make_polygon Return a polygon object containing all
            % cells within a cellobj array. Most useful for inter-connected
            % clusters of cells.
            %
            % SYNOPSIS: [x,y,flag] = make_polygon(obj_array,t,filename)
            %
            % INPUT: cellobj_array - has to be from the same embryo
            %        t - the frame of interest
            %        input- either just embyro-specific input or an array
            %               of input from EDGE_LOAD_SCRIPT
            %        filename - (optional) For saving into a CSV file
            % OUTPUT: x,y - coordinates of union of cells
            %         flag - if there is hole, will raise flag
            %
            % See also: POLYBOOL
            %
            % xies@mit.edu Oct 2013
            
            if numel( unique([obj_array.embryoID]) ) > 1
                error('Cells have to be from the same embryo!');
            end
            
            if numel(input) > 1
                input = input(obj_array(1).embryoID);
            end
            vx = cat(2,obj_array.vertex_x);
            vy = cat(2,obj_array.vertex_y);
            
            vx = cellfun(@(x) x*input.um_per_px,vx(t,:),'UniformOutput',0);
            vy = cellfun(@(x) x*input.um_per_px,vy(t,:),'UniformOutput',0);
            
%             % y-direction is off
%             vy = cellfun(@(x) input.Y-x,vy,'UniformOutput',0);
            
            warning('off','map:vectorsToGPC:noExternalContours');
            x = vx{1}; y = vy{1};
            for i = 2:numel(vx)    
                [x,y] = polybool('union',x,y,vx{i},vy{i});
            end
            [x,y] = poly2cw(x,y);
            x = x(1:end-1); y = y(1:end-1);
            
            if nargin > 3,
                csvwrite(filename, cat(2,x,y));
            end
            
        end % make_polygon

        function visualize(cells,ID,handle)
            %VISUALIZE_CELL Plots the raw area and myosin data for a given cell as well
            % as its fitted pulses, if applicable.
            %
            % USAGE: h = visualize_cell(cells,stackID)
            %
            % xies@mit.edu Feb 2013

            % Extract cell
            this_cell = cells.get_stackID(ID);

            nonan_frame = this_cell.dev_time;
            nonan_frame = ~isnan(nonan_frame);
            time = this_cell.dev_time( nonan_frame );

            if nargin < 3, handle = gca; end

            % Plot raw data: myosin + area
            [h,fig1,fig2] = plotyy(handle, time, this_cell.myosin_intensity(nonan_frame), ...
                time, this_cell.area_sm(nonan_frame) );

            set(fig1,'Color','g'); set(fig2,'Color','r');
            set(h(1),'YColor','g'); set(h(2),'YColor','r');

            % set x-axis limits
            set(h(2) , 'Xlim', [min(time) max(time)] );

            if this_cell.flag_fitted > 0 && this_cell.num_fits > 0

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
            
            h.border = 'off';
            h.frames2load = find(~isnan(this_cell.dev_time));
            
            % check that there are the measurements you're looking for...
            if ~isempty(this_cell.myosin_sm)
                h.channels = {'Membranes','Myosin','Membranes'};
            else
                h.channels = {'Membranes','Rho Kinase thresholded'};
            end
%             
%             if this_cell.flag_fitted
%                 h.measurement = nan(numel(h.frames2load),3);
%                 I = find( ismember(this_cell.fit_time, this_cell.dev_time) );
%                 h.measurement(I,:) = this_cell.fit_colorized;
%             end
            
            F = make_cell_img(h);
            
        end % movie


% ------------------------- Analysis --------------------------------------

        function [adj,nodes] = get_pulsing_trajectories(cells,fits)
            % GET_PULSING_TRAJECTORIES Construct a graph showing the
            % trajectory of a cell through pulse cluster-identity space
            % USAGE: [adj,nodes] =
            %        cells.get_pulsing_trajectories(fits);
            %
            % To visualize: wgPlot(adj,nodes)
            % Updated: xies@mit Jan 2014
            max_fits = nanmax( [cells.num_fits] );
            num_clusters = numel(unique([fits.cluster_label]));
            adj = zeros(num_clusters*max_fits + 2);
            
            for j = 1:numel(cells)
               
                % Grab current cell, its fits, and fit labels
                this_cell = cells(j);
                this_fits = fits.get_fitID(this_cell.fitID);
                % sort fits by timing
                [~,I] = sort([this_fits.center]);
                states = [this_fits(I).cluster_label];
                
                if ~isempty(states)
                    % Origin to first state
                    adj( 1,states(1) + 1 ) = adj( 1,states(1) + 1 ) + 1;
                    
                    for i = 1:numel( states ) - 1
                    %States are separated mod(num_clusters)
                        beg_index = num_clusters * (i - 1) + states(i) + 1;
                        end_index = num_clusters * i + states(i + 1) + 1;
                        adj( beg_index, end_index ) = ...
                            adj( beg_index, end_index ) + 1;
                        
                    end
                    
                    % Last state to end
                    adj( end_index, num_clusters*max_fits + 2) = ...
                        adj( end_index, num_clusters*max_fits + 2) + 1;
                end
            end
            
            x = zeros(num_clusters*max_fits + 2,1);
            y = zeros(num_clusters*max_fits + 2,1);
            
            % Construct the nodes
            % origin
            x(1) = 0; y(1) = (num_clusters + 1)/2;
            % ending
            x(end) = max_fits + 1; y(end) = (num_clusters + 1)/2;
            
            for i = 1:max_fits
                
                x( (i-1)*num_clusters + 2 : num_clusters*i + 1) = i;
                y( (i-1)*num_clusters + 2 : num_clusters*i + 1) = 1:num_clusters;
                
            end
%             k = 1:num_clusters*max_fits;
%             adj = adj(k,k);
            nodes = [ x y ];
            
        end % get_pulsing_trajectories
        
        function W = get_pulse_transition_matrix(cells,fits)
            %GET_PULSE_TRANSITION_MATRIX Constructs a matrix of the transition
            % rates of different types of pulses (pooled across time).
            %
            %
            
            num_behavior = numel(unique([fits.cluster_label]));
            
            % preallocate
            W = zeros(num_behavior);
            
            for i = 1:numel(fits)
                
                this_fit = fits(i);
                % fitID within this cell
                this_cellfitIDs = cells.get_stackID( this_fit.stackID).fitID;
                idx = find( this_cellfitIDs == this_fit.fitID );
                % if this fit is not the last one
                if idx < numel(this_cellfitIDs)
                    next_fitID = this_cellfitIDs( idx + 1 );
                    next_label = fits.get_fitID( next_fitID ).cluster_label;
                    
                    W( this_fit.cluster_label, next_label ) = ...
                        W( this_fit.cluster_label, next_label ) + 1;
                end
            end
            
        end
        
        function [adj,nodes] = get_pulse_transition_graph(cells,fits)
            %GET_PULSE_TRANSITION_GRAPH Constructs a matrix of the transition
            % rates of different types of pulses (pooled across time).
            
            num_behavior = numel(unique([fits.cluster_label]));
            
            % construct the nodes
            nodes = cat(1, ...
                cat(2,ones(num_behavior,1),(1:num_behavior)'), ...
                cat(2,2*ones(num_behavior,1),(1:num_behavior)') ...
                );
            
            % preallocate the adjacency matrix
            adj = zeros(2*num_behavior);
            for i = 1:numel(fits)
                
                this_fit = fits(i);
                % fitID within this cell
                this_cellfitIDs = cells.get_stackID( this_fit.stackID).fitID;
                idx = find( this_cellfitIDs == this_fit.fitID );
                % if this fit is not the last one
                if idx < numel(this_cellfitIDs)
                    next_fitID = this_cellfitIDs( idx + 1 );
                    next_label = fits.get_fitID( next_fitID ).cluster_label;
                    
                    adj( this_fit.cluster_label, next_label + num_behavior ) = ...
                        adj( this_fit.cluster_label, next_label + num_behavior ) + 1;
                end
            end
            
        end
        
        function angles = get_neighbor_angle(cellx,celly,frame)
            %GET_NEIGHBOR_ANGLE
            % Given a pair of cells, get the angle between their centroids (y wrt x,
            % along x-axis).
            %
            % Will flip all angles to lie within quadrant I. (i.e. use the
            % leftmost cell as a reference). Will return degrees.
            %
            % Optionally, will return a angle at a specific frame, if
            % supplied
            %
            % SYNOPSIS: angles = get_neighbor_angle(cell1,cell2);
            %           angle = get_neighbor_angle(cell1,cell2,frame);
            %
            % xies@mit March 2012
            
            % check that they're in the same embryo
            if cellx.embryoID ~= celly.embryoID, error('Cells not in same embryo!'); end
            
            angles = rad2deg(rad_flip_quadrant(atan2(...
                bsxfun(@minus,celly.centroid_y,cellx.centroid_y), ...
                bsxfun(@minus,celly.centroid_x,cellx.centroid_x) ) ) );
            
            if nargin > 2, angles = angles(frame); end
            if angles < -90 || angles > 90, keyboard; end
            
        end
        
        function [fits,cells] = bootstrap_stackID(cells,fits)
            %BOOTSTRAP_STACKID Randomly exchanges CellObj stackID with each
            % other (only fitted + tracked cells). Will also do same for
            % FITTED array.
            
            embryoIDs = unique([fits.embryoID]);
            for j = embryoIDs
                
                % extract cells belonging to this embryo (and also has a
                % Fitted object)
                c = cells.get_stackID([fits.get_embryoID(j).stackID]);
                
                % retain original index - for editing
%                 idx = find( ismember([cells.stackID],[c.stackID]) );
                fidx = { c.fitID };
                % new array of IDs
                sIDs = cat(1,c.stackID);
                cIDs = cat(1,c.cellID);
                % randpermute
                randIdx = randperm( numel(sIDs) );
                sIDs = sIDs( randIdx );
                cIDs = cIDs( randIdx );
                % rewrite cells and fits
                for k = 1:numel(c)
                    
%                     cells( idx(k) ).stackID = sIDs(k);
%                     cells( idx(k) ).cellID = cIDs(k);
                    
                    % Rewrite stackID in FITs
                    fIDs = [fits(ismember([fits.fitID], fidx{k})).fitID];
                    cells( [cells.stackID] == sIDs(k) ).fitID = fIDs;
                    
                    if any(fIDs)
                        fits = fits.set_stackID( fIDs, sIDs(k), cIDs(k) );
                    end
                end
            end
            % sort cells by stackID
            [~,I] = sort([cells.stackID],'ascend');
            cells = cells(I);
            
        end % bootstrap_stackID
        
        function binary = make_binary_sequence(cells,fits)
            %MAKE_BINARY_SEQUENCE Uses width_frames to generate a binary
            % sequence of pulses
			% USAGE: binary_seq = cells.make_binary_sequence(fits);
			
            % Preallocate
			binary = zeros( numel(cells(1).dev_time), max( [cells.cellID] ));
			% Filter relevant fits
			fits = fits.get_fitID( [cells.fitID] );

			for i = 1:numel(cells)

				this_cell_fits = fits.get_fitID( cells(i).fitID );
                if ~isempty(this_cell_fits)
                    for j = 1:numel( this_cell_fits )
                        binary( this_cell_fits(j).width_frames, cells(i).cellID ) = ...
                            binary( this_cell_fits(j).width_frames, cells(i).cellID ) + 1;
%                             this_cell_fits(j).cluster_label;
                    end
                end

			end
            
        end % make_binary_sequence
        
        
        function cells = rename_embryoID(cells,embryoID)
            % Rename all cells into a new embryoID
            % Please use from PULSE only to ensure FIT objects are
            % similarly renamed
            
            old_embryoID = cells(1).embryoID;
            [cells.embryoID] = deal(embryoID);
            
            for i = 1:numel(cells)
                fIDs = cells(i).fitID;
                tIDs = cells(i).trackID;
                % regular fits are base 1000 while manual ones are base
                % 10000
                base = 10.^floor(log10(fIDs) - log10(old_embryoID));
                fIDs = fIDs - old_embryoID*base + embryoID*base;
                base = 10.^floor(log10(tIDs) - log10(old_embryoID));
                tIDs = tIDs - old_embryoID*(base-base_corr) + embryoID*base;
                cells(i).fitID = fIDs;
                cells(i).trackID = tIDs;
                
            end
        end
        
   end % End methods 
   
end
