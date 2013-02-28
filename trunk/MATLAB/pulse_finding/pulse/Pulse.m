classdef Pulse
    properties (SetAccess = private)
        fits % Complete set of fits from ALL cells, including non-tracked and other embryos
        fitsOI_ID % fitID from only trakced cells in TRACKS
		fit_opt
        tracks
        tracks_mdf_file
        
        map
        match_thresh
        categories
        
    end %properties
    properties
        
        embryoID
        changes
        
    end
    methods %Dynamic methods
% --------------------------- Constructor -------------------
        function pulse = Pulse(tracks,filename,fits,fitsOI_ID,opts)
            if strcmp(class(tracks),'Track')
                pulse.fits = fits;
                pulse.tracks = tracks;
            else
                pulse.fits = tracks;
                pulse.tracks = fits;
            end
            pulse.tracks_mdf_file = filename;
			pulse.fit_opt = opts;
            pulse.fitsOI_ID = fitsOI_ID;
            
        end % Constructor
        
        function pulse = match_pulse(pulse,threshold)
            % Match fit and track
            nbm = MatchTrackFit(pulse.tracks,pulse.fits,threshold);
            pulse.map = nbm;
            pulse.match_thresh = threshold;
            
        end % match
        
%--------------------------- Mapping ------------------------------------------
        function pulse = categorize_mapping(pulse)
            %CATEGORIZE_MAPPING Quantify the different types of matches between
			% FITTED pulses and TRACK pulses.
			%
			% USAGE: pulse = categorize_mapping(pulse)
			% Updates the following class properties:
			%	pulse.categories.one2one - pulses with one FITTED and one TRACK
			%	pulse.categories.merge - one TRACK with multiple FITTED
			%	pulse.categories.split - multiple TRACK with single FITTED
			%	pulse.categories.miss - TRACK with no FITTED
			%	pulse.categories.add - FITTED with no TRACK
			%
			% xies@mit.edu Feb 2013.
            
            nbm = pulse.map;
            fit = pulse.fits.get_fitID(pulse.fitsOI_ID);
            track = pulse.tracks;
            
            % -------- Quantify merges --
            [trackID,fitID] = find_merges(nbm.dictTrackFit);
            [ matches.merge( 1:numel(trackID) ).trackID ] = deal(trackID{:});
            [ matches.merge( 1:numel(trackID) ).fitID ] = deal(fitID{:});
            % Annotate fit/track with merges
            for i = 1:numel(trackID)
                %                 keyboard
                [ fit( ismember([fit.fitID], fitID{i}) ).category ] = deal('merge');
                [ track( ismember([track.trackID], trackID{i}) ).category ] = deal('merge');
            end
            
            % ------- Quantify splits --
            [fitID,trackID] = find_merges(nbm.dictFitTrack);
            [ matches.split( 1:numel(trackID) ).fitID ] = deal(fitID{:});
            [ matches.split( 1:numel(trackID) ).trackID ] = deal(trackID{:});
            % Annotate fit/track with splits
            for i = 1:numel(trackID)
                [ fit( ismember([fit.fitID], fitID{i}) ).category ] = deal('split');
                [ track( ismember([track.trackID], trackID{i}) ).category ] = deal('split');
            end
            
            % ------- Quantify missed/added --
            matchedTF_trackID = nbm.dictTrackFit.keys; %fitID
            matchedFT_fitID = nbm.dictFitTrack.keys; %trackID
            % misses
            trackID = ...
                [ track(~ismember([track.trackID],cell2mat(matchedTF_trackID))).trackID ];
            % Annotate track with misses
            for i = 1:numel(trackID)
                matches.miss(i).trackID = trackID(i);
                matches.miss(i).fitID = [];
            end
            [ track( ismember([track.trackID],[matches.miss.trackID])).category ] = deal('miss');
            % adds
            fitID = ...
                [ fit(~ismember([fit.fitID],cell2mat(matchedFT_fitID))).fitID ];
            for i = 1:numel(fitID)
                matches.add(i).fitID = fitID(i);
                matches.add(i).trackID = [];
            end
            % Annotate track with adds
            [ fit( ismember([fit.fitID],[matches.add.fitID])).category ] = deal('add');
            
            % -- Quantify one-to-one matches --
            % Find all tracks within the fit-fitted cells, and not belonging to
            % merge/split/miss
            one2one_origins = [track( ...
                ~ismember([track.trackID], unique([matches.merge.trackID matches.split.trackID])) ...
                & ~ismember([track.trackID], [matches.miss.trackID]) ...
                & ismember([track.trackID], cell2mat(nbm.dictTrackFit.keys)) ).trackID];
            % initialize
            [one2one(1:numel(one2one_origins)).trackID] = deal([]);
            [one2one(1:numel(one2one_origins)).fitID] = deal([]);
            % Assign
            for i = 1:numel(one2one_origins)
                one2one(i).trackID = one2one_origins(i);
                one2one(i).fitID = nbm.dictTrackFit( one2one_origins(i) );
            end
            % Annotate one2one matches ontp fit/track structures
            [ track( ismember([track.trackID],[one2one.trackID]) ).category] = deal('one2one');
            [ fit( ismember([fit.fitID],[one2one.fitID]) ).category] = deal('one2one');
            % Collect into structure
            matches.one2one = one2one;
            
            % Delete empty fields
            matches = delete_empty(matches);
            
            pulse.fits = fit;
            pulse.tracks = track;
            pulse.categories = matches;
            if ~consistent(pulse,matchedTF_trackID,matchedFT_fitID)
                error('Something doesn''t add up!');
            end
            
            % -- Subfunctions of categorize_mapping -- %
            function flag2cont = consistent(pulse,matchedTF_trackID,matchedFT_fitID)
                match = pulse.categories;
                num_tracks = numel(pulse.tracks);
                num_fit = numel(pulse.fits);
                flag2cont = num_tracks ~= ...
                    numel(match.one2one) + numel(match.miss.trackID) ...
                    + numel([match.merge.trackID]);
                flag2cont = flag2cont || ...
                    num_fit ~= numel(match.one2one) + numel(match.add.fitID) ...
                    + numel([match.add.fitID]);
                flag2cont = flag2cont || ...
                    numel(matchedTF_trackID) ~= numel(match.one2one) ...
                    + numel([ match.merge.trackID ]) + numel([ match.split.trackID ]);
                flag2cont = flag2cont || ...
                    numel(matchedFT_fitID) ~= numel(match.one2one) ...
                    + numel([ match.merge.fitID ]) + numel([ match.split.fitID ]);
            end
            function match = delete_empty(match)
                if isempty( [match.one2one.trackID] )
                    match = rmfield(match,'one2one');
                end
                if isempty( [match.merge.trackID] )
                    match = rmfield(match,'merge');
                end
                if isempty( [match.split.trackID] )
                    match = rmfield(match,'split');
                end
                if isempty( [match.miss.trackID] )
                    match = rmfield(match,'miss');
                end
                if isempty( [match.add.fitID] )
                    match = rmfield(match,'add');
                end
            end
            % --- End categorize_mapping subfunctions
        end % Categorize_mapping

		function catID = search_catID(pulse,type,pulseID)
			% SEARCH_CATID Search for the category_index (catID) of a pulse
			% (track/fit).
			if strcmpi(type,'fit')
				this = pulse.get_fitID(pulseID);
				ID = 'fitID';
			else
				this = pulse.get_trackID(pulseID);
				ID = 'trackID';
			end
			category = this.category;
			curr_cat = pulse.categories.(category);
			catID = cellfun(@(x) ismember( pulseID, x ), ...
                {category.(ID)});
			catID = find(catID);

		end
        
%--------------------- edit pulse/tracks ----------------------------------
        
        function pulse = removePulse(pulse,type,pulseID)
            %REMOVEPULSE Remove pulse from track-fit mapping, as well as
            % the respective pulse object array.
            %
            % USAGE: pulse = removePulse(pulse,'fit',fitID);
            %
            % xies@mit.edu
            new_nbm = pulse.map.removeElement(pulseID,type);
            pulse.map = new_nbm;
            % Remove pulse from stack
            switch type
                case 'fit'
                    indices = ismember([pulse.fitsOI_ID], pulseID);
                    if ~any(indices)
                        display('Cannot remove FITTED: given fitID does not exist.');
                        return
                    end
                    pulse.fitsOI_ID( indices ) = [];
                    pulse.fits( indices ) = [];
                case 'track'
                    indices = ismember([pulse.tracks.trackID], pulseID);
                    if ~any(indices)
                        display('Cannot remove TRACK: given trackID does not exist.');
                        return
                    end
                    pulse.tracks( indices ) = [];
                otherwise
                    error('Invalid type: expecting TRACK or FIT.')
            end
            
            % Redo categorizing
            pulse = pulse.categorize_mapping;
            
        end %removePulse
        
        function pulse = createTrackFromFit(pulse,fitID)
            %@Pulse.createTrackFromFit Convert a fitted pulse into an
            %'artificial track'. Useful when dealing with the 'add'
            % category.
            %
            % USAGE: pulse = pulse.createTrackFromFit(fitID);
            
            fit = pulse.fits.get_fitID(fitID);
            if isempty(fit), error('No FIT found with fitID.'); end
            % Add to tracks stack
            this_track.embryoID = fit.embryoID;
            this_track.cellID = fit.cellID;
            this_track.stackID = fit.stackID;
            this_track.dev_frame = fit.width_frames;
            this_track.embryoID = fit.embryoID;
            this_track.dev_time = ensure_row(fit.dev_time);
            this_track.img_frame = ensure_row(fit.img_frames);
            
            tracks = add_track(pulse.tracks,this_track);
            
            % Rematch the track/fit mappings
            pulse_new = pulse;
            pulse_new.tracks = tracks;
            pulse_new = pulse_new.match_pulse(pulse.match_thresh); % Redo match
            pulse_new = pulse_new.categorize_mapping;
            
            pulse = pulse_new;
            
        end % createTrackFromFit

		function pulse = createFitFromTrack(pulse,cells,trackID,opt)
            
			track = pulse.tracks.get_trackID(trackID);
			if isempty(track), error('Cannot create FIT: No track with trackID found.'); end
			this_fit.embryoID = track.embryoID;
			this_fit.cellID = track.cellID;
			this_fit.stackID = track.stackID;
            
            this_cell = cells(track.stackID);
            num_frames = numel(this_cell.dev_frame);
            params = manual_fit([mean(track.dev_time) 20],cells,track.stackID);

			% Get parameters
			this_fit.amplitude = params(1);
			this_fit.center = params(2);
			this_fit.width = params(3);
            
            % Get dev frames
            center_frame = findnearest( this_cell.dev_time, params(2) );
            [left_margin,pad_l] = max([ center_frame - opt.left_margin, 1 ]);
            [right_margin,pad_r] = min([ center_frame + opt.right_margin, num_frames ]);
			this_fit.margin_frames = left_margin:right_margin;
            
            % Get width frames
            left_width = max( center_frame - ...
                findnearest(params(3), cumsum(diff(this_cell.dev_time)), 1));
            right_width = min( center_frame + ...
                findnearest(params(3), cumsum(diff(this_cell.dev_time)), num_frames));
			this_fit.width_frames = left_width : right_width;
            
			this_fit.img_frames = this_cell.dev_frame(left_width:right_width);
			this_fit.dev_time = this_cell.dev_time(left_width:right_width);
            
            % Get curves
			Y = this_cell.(opt.to_fit);
            x = this_cell.dev_time(left_margin:right_margin);
            this_fit.raw = Y(left_margin:right_margin);
			fitted_y = lsq_gauss1d(params,x);
            this_fit.fit = fitted_y;
			this_fit.aligned_time = x - this_fit.center;

            % Get padded objects
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
            
            fits = add_fit(pulse.fits,this_fit);
            pulse.fitsOI_ID = [pulse.fitsOI_ID fits(end).fitID];
            pulse.fits = fits;
            pulse = pulse.match_pulse(pulse.match_thresh); % Redo match
            pulse = pulse.categorize_mapping;
            
        end

%---------------------- graph/display -------------------------------------
        
        function varargout = graph(pulse,cat,cells,ID,axes_handle)
            % Graph the selected cateogry
            % USAGE: pulse.graph(category,cells,ID,handles)
            %        pulse.graph(category,cells,ID)
            %
            % INPUT: category - string corresponding to category name, e.g.
            %               'one2one' or 'merge'
            %        cells - cells structure (for plotting)
            %        ID - out of this category, a vector of IDs
            %        handles.axes - subplot axes
            
            % get the data
            fits = pulse.fits; tracks = pulse.tracks;
            
            % find number of things to graph
            category = pulse.categories.(cat);
            num_disp = numel(ID);
            
            % handles
            
            for i = 1:num_disp
                
                % obtain relevant highlight IDs (could be empty)
                fitID = category(ID(i)).fitID;
                trackID = category(ID(i)).trackID;
                % Get stackID
                if ~isempty(trackID), stackID = tracks.get_trackID(trackID(1)).stackID;
                else stackID = fits.get_fitID(fitID(1)).stackID; end
                
                % Get time (for graphing
                dev_time = cells(stackID).dev_time;
                
                % Extract fit/track of interest
                track = tracks.get_stackID(stackID); num_track = numel(track);
                fit = fits.get_stackID(stackID ); num_fit = numel(fit);
                
                % --- Plot tracked pulses ---
                % handle subplots, plot to alternative parent if applicable
                if nargin > 4
                    h(1) = subplot(3, num_disp, i, 'Parent', axes_handle);
                else
                    h(1) = subplot(3, num_disp, i);
                end
                axes(h(1));
                binary_trace = concatenate_pulse(track,dev_time); % get binary track
                if ~isempty(trackID) % highlight pulse if applicable
                    on = highlight_track(track,trackID);
                    binary_trace(on,:) = binary_trace(on,:) + 3;
                end
                if num_track > 1 % Plot
                    %                     if nargin > 4
                    imagesc(dev_time,1:num_track,binary_trace,'Parent',h(1));
                    
                elseif num_track == 1
                    plot(h(1),dev_time,binary_trace);
                else
                    cla(h(1));
                end
                set(h(1),'Xlim',[min(dev_time) max(dev_time)]);
                xlabel(h(1),'Develop. time (sec)');
%                 title(h(1),['Manual: #' num2str(track(1).trackID)])
                
                % --- Plot fitted pulses ---
                if nargin > 4
                    h(2) = subplot(3, num_disp, num_disp + i, 'Parent', axes_handle);
                else
                    h(2) = subplot(3, num_disp, num_disp + i);
                end
                axes(h(2));
                binary_trace = concatenate_pulse(fit,dev_time); % get binary track
                if ~isempty(fitID) % highlight pulse if applicable
                    on = highlight_track(fit,fitID);
                    binary_trace(on,:) = binary_trace(on,:) + 3;
                end
                if num_fit > 1 % Plot
                    imagesc(dev_time,1:num_fit,binary_trace,'Parent',h(2));
                elseif num_fit == 1
                    plot(h(2),dev_time,binary_trace);
                else
                    cla(h(2));
                end
                set(h(2),'Xlim',[min(dev_time) max(dev_time)]);
                xlabel(h(2),'Develop. time (sec)');
                title(h(2),['Fitted'])
                
                % --- Plot cell raw data ---
                if nargin > 4
                    h(3) = subplot(3, num_disp, 2*num_disp + i, 'Parent', axes_handle);
                else
                    h(3) = subplot(3, num_disp, 2*num_disp + i);
                end
                visualize_cell(cells, stackID, h(3));
                linkaxes( h , 'x');
                
            end % End of for-loop
            
            if nargout > 0
                varargout{1} = [tracks.get_stackID(stackID).trackID];
                varargout{2} = [fits.get_stackID(stackID).fitID];
            end
            
            % --- Sub functions ---
            function binary = concatenate_pulse(pulse,time)
                % Creates a binary track of all pulses
                binary = zeros(numel(pulse),numel(time));
                if strcmp(class(pulse),'Fitted'), frames = {pulse.width_frames};
                else frames = {pulse.dev_frame}; end
                for j = 1:numel(pulse)
                    binary(j,frames{j}) = 1;
                end
            end
            function on = highlight_track(pulse,ID)
                % Parse the ID field and match the correct pulse to highlight
                if strcmp(class(pulse),'Fitted')
                    on = ismember([pulse.fitID],ID);
                else
                    on = ismember([pulse.trackID],ID);
                end
            end
            % ---- End subfunctions ----
            
        end % graph
        
        function disp(pulse)
            %---- Display overloaded method ---
            fprintf('\n')
            display('------ Tracked pulses ---------- ')
            display(['Total tracked pulses: ' num2str(numel(pulse.tracks))])
            display('------ Fitted pulses ----------- ')
            display(['Total fitted pulses: ' num2str(numel(pulse.fits))])
            fprintf('\n')

            display('------ Matching ---------------- ')
			if isfield(pulse.categories,'one2one')
				num_one2one = numel( pulse.categories.one2one );
			else
				num_one2one = 0;
			end
            display( ['One-to-one matches: ' num2str(num_one2one)] );
			
			if isfield(pulse.categories,'merge')
				num_merge = numel( pulse.categories.merge );
			else
				num_merge = 0;
			end
            display( ['Merged (by fit): ' num2str(num_merge)] )

			if isfield(pulse.categories,'split')
				num_split = numel( pulse.categories.split );
			else
				num_split = 0;
			end
            display(['Split (by fit): ' num2str(num_split)])

			if isfield(pulse.categories,'miss')
				num_miss = numel( pulse.categories.miss );
			else
				num_miss = 0;
			end
            display(['Missed (by fit): ' num2str(num_miss)])

			if isfield(pulse.categories,'add')
				num_add = numel( pulse.categories.add );
			else
				num_add = 0;
			end
            display(['Added (by fit): ' num2str(num_add)])
            fprintf('\n')
            
        end % display
        
%         function diff(pulse1,pulse2)
%             %---- Difference display ----
% %             num
%             
%         end
        
    end % Dynamic methods
    
end
