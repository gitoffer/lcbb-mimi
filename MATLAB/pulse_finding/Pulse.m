classdef Pulse
    %--- PULSE ------------------------------------------------------------
	%A housekeeping class to keep track of TRACK pulses and FITTED pulses,
	% as well as the bi-directional correspondence between the two sets.
	%
	% Matches tracked pulses (TRACK) to fitted pulses (FITTED), with a generalized
	% class MatchTrackFit to handle the two-way mapping between the two sets of
	% objects, which could contain the following categories:
	%	1) one-to-one matches
	%	2) missed objects from either set
	%	3) objects from one set mapped onto the same object in the other.
	%
	% Methods are implemented to handle manual adjustment to the correspondence
	% to resolve missed objects, as well as merged objects. To this end a graphical
	% output is also implemented under @pulse.graph.
	% 
	% Properties (private)
	%	fits - the complete array of all fits, does not have to exclude non-tracked
	%		cells/embryos
	%	fitsOI_ID - the fitID (unique ID code for each fitted pulse) of interest, i.e.
	%		those from cells with tracked pulses
	%	tracks - the array of TRACK pulses for this embryo
	%	tracks_mdf_file - the MDF filename
	%	cells - an array of CELLOBJ of data from cells found in this embryo
	%
	% Properties (public)
	% 	embryoID - the index of this embryo (see also LOAD_EDGE_SCRIPT)
	%	changes - a structure containing information about the manual changes
	%		performed on the PULSE object
	%
	% Methods
	% 
	% --- Construction methods ---
	%	Pulse - constructor object
	%	.match_pulse - performs matching between .tracks and .fits, and constructs
	%		the .map property from the resulting two-way mapping
	%	.categorize_mapping - creates/updates the .categories property from the .map
	%		includes the following fields:
	%		.one2one - one-to-one matches
	%		.merge - two Track per Fitted
	% 		.split - one Track per two Fitted
	%		.miss - Track with no Fitted
	% 		.add - Fitted with no Track
    %   .search_catID Search for the category_index (catID) of a pulse
    %       (track/fit).
    %   .cat - concatenate two Pulse objects (for example from different
    %       embryos)
	% --- Manual editing methods ---
    %   rename_embryoID - consistently renames the embryoID
	%	search_catID - given a tracked or fit from a PULSE object, find the index
	%		of that object within its current .cagetory
	%	removePulse - remove a track/fit and update the mapping
	%	createFitFromTrack - create an artificial FITTED from roughly where a TRACK
	%		was... uses MANUAL_FIT
	%	createTrackFromFit - create an artificial TRACK from roughly where a FITTED
	%		was...
	%	reassignFit - re-assign a FITTED to a TRACK, will only work if neither have
	% 		prior assignments
	%	read_changes - given a .change structure, edit current Pulse object
    %   adjust_centers - adjust the reference time used to construct
    %       dev_time
    %
    % --- Saving methods ---
    %   export_manual_fits - writes manually fitted parameters into a CSV
    %       file
	%	export_changes - writes all changes into a CSV
	% --- Display methods ---
	%	graph - Generates a 1x3 subplot of the TRACK/FIT/CELL
	% 	display - In-line display, reporting the number of objects and the quality of
	%		matching
    %
    % See also: CELLOBJ, FITTED, TRACK, FIND_ONE2ONE
	%
	% xiies@mit.edu April 2013.

    properties (SetAccess = private)
        
        fits 		% Complete set of FITTED pulses from ALL cells, including non-tracked and other embryos
        fitsOI_ID 	% fitID from only trakced cells in TRACKS
		fit_opt 	% The fitting option file for this embryo
        tracks 		% Set of TRACK pulses for this embryo
        tracks_mdf_file % The filename of the MDF file from which .tracks was loaded
        cells 		% An array of CELL of cells in this embryo (Contains the raw data)
        input      % input array with info about identifiy of each embryo
        next_fitID  % bookkeeping
        
        map			% The two-way mapping between Track and Fit
        match_thresh % The threshold of frames overlap above which a TRACK and a FITTED is matched (usually 1)
        categories %  A structure containing the different categories of matches
        
    end %properties
    properties
        
        embryoID
        changes
        
    end
    methods % Dynamic methods
% --------------------------- Constructor -------------------
        function pulse = Pulse(tracks,filename,fits,opts,cells,input)
			%PULSE Constructor for the Pulse object (see main documentation)
			% Will not generate the .map property.
			%
			% USAGE: pulse = Pulse(tracks,mdf_filename,fits,fit_opt,cells,input);
            
            if nargin > 0 % empty case (for object arrays)

				% Make sure that tracks are from the same embryo
				if any( [tracks.embryoID] ~= tracks(1).embryoID ),
					error('Error making Pulse object: Tracks need to come from the same embryo');
				end
                
                if strcmp(class(tracks),'Track')
                    pulse.fits = fits;
                    pulse.tracks = tracks;
                else
                    pulse.fits = tracks;
                    pulse.tracks = fits;
                end
                
                fitsOI_ID = [fits( ... filter out non-tracked cells
                    ismember( [fits.stackID], [tracks.stackID] )).fitID];
                
                pulse.tracks_mdf_file = filename;
                pulse.input = input;
                pulse.fitsOI_ID = fitsOI_ID;
                pulse.next_fitID = fits.get_fitID(fitsOI_ID(1)).embryoID*100000;
                pulse.fit_opt = opts( fits.get_fitID(fitsOI_ID(1)).embryoID );

				% Take only cells from the same embryoID
                cells = cells( [cells.embryoID] == tracks(1).embryoID );
                pulse.cells = cells;
                
                save([fileparts(pulse.tracks_mdf_file) '/pulse_raw.mat'], 'pulse');
                
            end % non-empty constructor
        end % Constructor
        
        function pulse = match_pulse(pulse,threshold)
            %MATCH_PULSE Match FITTED objects to TRACK objects by generating a
			% MatchTrackFit object, which is a wrapper for interacting with two
			% container.Map objects (hashmaps).
			%
			% USAGE: pulse = match_pulse(pulse, threshold)

			if isempty(pulse.map) || ...
				 (~isempty(pulse.match_thresh) && pulse.match_thresh ~= threshold)
				pulse.categories = [];
				pulse.changes = [];
			end
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
            matches.miss.trackID = [];
            matches.miss.fitID = [];
            for i = 1:numel(trackID)
                matches.miss(i).trackID = trackID(i);
                matches.miss(i).fitID = [];
                track( [track.trackID] == trackID(i) ).category = 'miss';
            end

            % adds
            matches.add.trackID = [];
            matches.add.fitID = [];
            fitID = ...
                [ fit(~ismember([fit.fitID],cell2mat(matchedFT_fitID))).fitID ];
            for i = 1:numel(fitID)
                matches.add(i).fitID = fitID(i);
                matches.add(i).trackID = [];
                fit( [fit.fitID] == fitID(i) ).category = 'add';
            end
            
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
            
            % -- Subfunctions of categorize_mapping -- %
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
			%SEARCH_CATID Search for the category_index (catID) of a pulse
			% (track/fit). Will use the .category property of the given
			% FITTED/TRACK.
			%
			% USAGE: catID = search_catID(pulse,'fit',fitID)
			% 		 catID = search_catID(pulse,'track',trackID)
			
			if strcmpi(type,'fit')
				this = pulse.get_fitID(pulseID);
				ID = 'fitID';
			else
				this = pulse.get_trackID(pulseID);
				ID = 'trackID';
			end
			category = this.category;
% 			curr_cat = pulse.categories.(category);
			catID = cellfun(@(x) ismember( pulseID, x ), ...
                {category.(ID)});
			catID = find(catID);

        end %search_catID
        
        function pulse = cat(pulse1,pulse2)
            %CAT - overloaded concatenation method for putting together two
            % Pulse objects. Will look through embryoIDs to ensure there
            % are no colliding ID numbers.
            
            pulse = pulse1;
            embryoIDs1 = [pulse1.embryoID]; embryoIDs2 = [pulse2.embryoID];
            
            % find colliding/not colliding embryoIDs
            conflicting_embryoIDs = union( embryoIDs1, embryoIDs2 );
            
            if isempty( conflicting_embryoIDs)
                pulse = [pulse pulse2];
            else
                
                for i = 1:numel(conflicting_embryoIDs)
                    
                    this_embryo_pulse = [pulse2.embryoIDs];
                    % new embryoID is +1 to max embryoIDs
                    new_embryoID = max([embryoIDs1,embryoIDs2]) + 1;
                    % reindex fitIDs
                    this_embryo_pulse.fits = ...
                        this_embryo_pulse.fits.reindex_fitID(new_embryoID);
                    % reindex trackIDs
                    this_embryo_pulse.tracks = ...
                        this_embryo_pulse.tracks.reindex_trackID(new_embryoID);
                    
                    pulse = [pulse this_embryo_pulse];
                    
                end
                
            end
            
        end % cat
        
%--------------------- edit pulse/tracks ----------------------------------
        
        function pulse = rename_embryoID(pulse,embryoID)
            % Rename all the FITTED and CELLOBJ from an old embryoID into a
            % new embryoID.
            pulse.fits = pulse.fits.rename_embryoID(embryoID);
            pulse.cells = pulse.cells.rename_embryoID(embryoID);
        end

        function pulse = removePulse(pulse,type,pulseID)
            %@Pulse.removePulse Remove pulse from track-fit mapping, as well as
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
                    % Remove from cell obj
                    stackID = [pulse.fits.get_fitID(pulseID).stackID];
                    pulse.cells( [pulse.cells.stackID] == stackID ) = ...
                        pulse.cells( [pulse.cells.stackID] == stackID ).removeFit(pulseID);
                    
                    % Remove from fits stack
                    pulse.fits = pulse.fits.removeFit( pulseID );
                    pulse.fitsOI_ID(pulse.fitsOI_ID == pulseID) = [];
                    
                    % Record
                    if isfield(pulse.changes,'fitIDRemoved')
                        pulse.changes.fitIDRemoved = ...
                            [pulse.changes.fitIDRemoved pulseID];
                    else
                        pulse.changes.fitIDRemoved = pulseID;
                    end
                    
                    display(['Deleting fitID: ' num2str(pulseID)]);
                    
                case 'track'
                    indices = ismember([pulse.tracks.trackID], pulseID);
                    if ~any(indices)
                        display('Cannot remove TRACK: given trackID does not exist.');
                        return
                    end
                    % Remove from CellObj
                    stackID = [pulse.tracks(indices).stackID];
                    for i = 1:numel(stackID)
                        pulse.cells( [pulse.cells.stackID] == stackID(i)) = ...
							pulse.cells( [pulse.cells.stackID] == stackID(i)).removeTrack(pulseID);
                    end
                    % Remove from track stack
                    pulse.tracks( indices ) = [];
                    if isfield(pulse.changes,'trackIDRemoved')
                        pulse.changes.trackIDRemoved = ...
                            [pulse.changes.trackIDRemoved pulseID];
                    else
                        pulse.changes.trackIDRemoved = pulseID;
                    end
                    
                    display(['Deleting trackID: ' num2str(pulseID)]);
                    
                otherwise
                    error('Invalid type: expecting TRACK or FIT.')
            end
            
            % Redo categorizing
            pulse = pulse.match_pulse(pulse.match_thresh);
            pulse = pulse.categorize_mapping;
            
        end %removePulse
        
        function pulse = createTrackFromFit(pulse,fitID)
            %@Pulse.createTrackFromFit Convert a fitted pulse into an
            %'artificial track'. Useful when dealing with the 'add'
            % category.
            %
            % USAGE: pulse = pulse.createTrackFromFit(fitID);
            
            fit = pulse.fits.get_fitID(fitID);
            if isempty(fit), display('No FIT found with fitID.'); return; end
            if isfield(pulse.changes,'tracksMadeFromFit')
                if any( fitID == [pulse.changes.tracksMadeFromFit.fitID])
                    display(['Fit #' num2str(fitID) ' already used to add a track.']);
                    return
                end
            end
            
            display(['Creating track from fitID ' num2str(fitID)]);
            
            % Add to tracks stack
            this_track.embryoID = fit.embryoID;
            this_track.cellID = fit.cellID;
            this_track.stackID = fit.stackID;
            this_track.dev_frame = fit.width_frames;
            this_track.embryoID = fit.embryoID;
            this_track.dev_time = ensure_row(fit.dev_time);
            
            tracks = add_track(pulse.tracks,this_track);
            
            % Rematch the track/fit mappings
            pulse_new = pulse;
            pulse_new.tracks = tracks;
            pulse_new = pulse_new.match_pulse(pulse.match_thresh); % Redo match
            pulse_new = pulse_new.categorize_mapping;
            
            pulse = pulse_new;
            
            pulse.cells([pulse.cells.stackID] == fit.stackID) = ...
                pulse.cells([pulse.cells.stackID] == fit.stackID ).addTrack( pulse.tracks(end).trackID);
            
            % Record changes
            this_change.trackID = pulse.tracks(end).trackID;
            this_change.fitID = fitID;
            if isfield(pulse.changes,'tracksMadeFromFit')
                pulse.changes.tracksMadeFromFit = ...
                    [pulse.changes.tracksMadeFromFit this_change];
            else
                pulse.changes.tracksMadeFromFit = this_change;
            end
            
        end % createTrackFromFit

		function pulse = createFitFromTrack(pulse,trackID,opt)
            %@Pulse.createFitFromTrack Using the stackID/embryoID and timing to create an
			% artificial 'fit'.
			%
			% USAGE: pulse = pulse.createFitFromTrack(cells,trackID,fit_opt)
			% xies@mit.edu Feb 2013
            
            cells = pulse.cells;

			% Extract track / make sure it's not duplicated
			track = pulse.tracks.get_trackID(trackID);
			if isempty(track), display('Cannot create FIT: No track with trackID found.'); return; end
            if isfield(pulse.changes,'fitsMadeFromTrack');
                if any(trackID == [pulse.changes.fitsMadeFromTrack.trackID])
                    display(['Track ID' num2str(trackID) ' already used to add a fit.']);
                    return
                end
            end
            
            display(['Creating fit from trackID ' num2str(trackID)])
            
            % Load already manually fitted params
            try already_done = ...
                csvread( [ fileparts(pulse.tracks_mdf_file), '/', 'manual_fits.csv' ] );
            catch err
                if strcmpi(err.identifier,'MATLAB:csvread:FileNotFound')
                    already_done = NaN;
                else
                    rethrow(err);
                end
            end
            
            I = find( already_done(:,1) == trackID );
            if ~isempty(I)
                % If already_done, then load recorded change
                params = already_done( I , 2:4 );
            else
				% Launch the manual fit GUI
        	    params = manual_fit( ...
            	    [mean(track.dev_time) 20],cells,track.stackID);
            end
            
            % Construct a new FITTED object from parameters
            new_fit = Fitted( cells([cells.stackID] == track.stackID), ...
                params, pulse.next_fitID, opt);
            pulse.next_fitID = pulse.next_fitID + 1; %increment fitIDs
            
            % Add into stack
            [fits,errorflag] = pulse.fits.add_fit(new_fit);
            if errorflag, return; end
            fits(end).manually_added = 1;
            
            pulse.fitsOI_ID = [pulse.fitsOI_ID fits(end).fitID];
            pulse.fits = fits;
            
            % Redo match/categorizing
            pulse = pulse.match_pulse(pulse.match_thresh);
            pulse = pulse.categorize_mapping;
           
            % Update cell tracklist
            pulse.cells( [pulse.cells.stackID] == track.stackID ) = ...
                pulse.cells( [pulse.cells.stackID] == track.stackID).addFit( pulse.fits(end));
            
            % Record changes
            this_change.fitID = pulse.fits(end).fitID;
            this_change.trackID = trackID;
            if isfield(pulse.changes,'fitsMadeFromTrack')
                pulse.changes.fitsMadeFromTrack = ...
                    [pulse.changes.fitsMadeFromTrack this_change];
            else
                pulse.changes.fitsMadeFromTrack = this_change;
            end
            
        end % createFitFromTrack

		function pulse = reassignFit(pulse,fitID,newTrackID)
			%@Pulse.reassginFit Reassign FIT to TRACK: works only if neither
			% FIT and TRACK have been assigned previously.
			nbm = pulse.map.reassign(newTrackID,fitID);
			pulse.map = nbm;            
            pulse = pulse.categorize_mapping;
            
            this_change.trackID = newTrackID;
            this_change.fitID = fitID;
            if isfield(pulse.changes,'reassignedTrackFit')
                pulse.changes.reassignedTrackFit = ...
                    [pulse.changes.reassignedTrackFit, this_change];
            else
                pulse.changes.reassignedTrackFit = this_change;
            end
            
        end % reassignFit
		
		function pulse = read_changes( pulse, changes )
            % READ_CHANGES Make edits to track/fit given recorded changes
            
            if isfield(changes,'fitsMadeFromTrack')
                trackIDs = changes.fitsMadeFromTrack;
                trackIDs = [trackIDs.trackID];
                for i = 1:numel(trackIDs)
                    opt = pulse.fit_opt;
                    pulse = pulse.createFitFromTrack(trackIDs(i),opt);
                end
            end
            
            if isfield(changes,'tracksMadeFromFit')
                fitIDs = changes.tracksMadeFromFit;
                fitIDs = [fitIDs.fitID];
                for i = 1:numel(fitIDs)
                    pulse = pulse.createTrackFromFit(fitIDs(i));
                end
            end
            if isfield(changes,'fitIDRemoved')
                fitIDs = [changes.fitIDRemoved];
                for i = 1:numel(fitIDs)
                    pulse = removePulse(pulse,'fit',fitIDs(i));
                end
            end
            if isfield(changes,'trackIDRemoved')
                trackIDs = [changes.trackIDRemoved];
                for i = 1:numel(trackIDs)
                    pulse = removePulse(pulse,'track',trackIDs(i));
                end
            end
            if isfield(changes,'reassignedTrackFit')
                changes = changes.reassignedTrackFit;
                for i = 1:numel(changes)
                    pulse = reassignFit(pulse,changes.fitID,changes.trackID);
                end
            end
            
            save( [fileparts(pulse.tracks_mdf_file), '/', 'pulse_curated.mat'], 'pulse');
			
		end % read_changes
        
        function pulse = adjust_centers(pulse,old_tref,new_tref,dt)
            if numel(pulse) > 1
                error('Only one embryo please.')
            end
            pulse.cells = pulse.cells.adjust_centers(old_tref,new_tref,dt);
            pulse.fits = pulse.fits.adjust_centers(old_tref,new_tref,dt);
            
        end
        
% ----------------------- saving ------------------------------------------

        function export_manual_fits(pulse)
            %EXPORT_MANUAL_PULSES
            % Writes down the manual fit parameters for fits created from
            % tracks. Saveas as manual_fit.csv
        changes = pulse.changes;
        if isfield(changes,'fitsMadeFromTrack')
            num_changes = numel(changes.fitsMadeFromTrack);
        else
            num_changes = 0;
        end

        mat2write = nan(num_changes,4);

        for i = 1:num_changes
            this_change = changes.fitsMadeFromTrack(i);

            trackID = this_change.trackID;
            fitID = this_change.fitID;

            this_fit = pulse.fits.get_fitID(fitID);
            if ~isempty(this_fit)
                params = [this_fit.amplitude this_fit.center this_fit.width];
                mat2write(i,1) = trackID;
                mat2write(i,2:4) = params;
            end
        end

        if isfield(changes,'fitsMadeFromTrack')
            csvwrite( [fileparts(pulse.tracks_mdf_file), '/', 'manual_fits.csv'], ...
            mat2write );
        end
        
        end % export_manual_fits
		
		function export_changes( pulse )
			%EXPORT_CHANGES
			% Export all .changes to a .mat file
			
			changes = pulse.changes;
			save( [fileparts(pulse.tracks_mdf_file), '/', 'changes.mat'], 'changes');
            
            % export manual changes
            pulse.export_manual_fits;
			
		end % export_changes

% ---------------------- graph/display ------------------------------------
        
        function varargout = graph(pulse,cat,ID,axes_handle)
            % Graph the selected cateogry
            % USAGE: pulse.graph(category,ID,handles)
            %        pulse.graph(category,ID)
            %
            % INPUT: category - string corresponding to category name, e.g.
            %               'one2one' or 'merge'
            %        ID - out of this category, a vector of IDs
            %        axes_handle - subplot axes
            
            % get the data
            fits = pulse.fits; tracks = pulse.tracks; cells = pulse.cells;
            
            % find number of things to graph
            category = pulse.categories.(cat);
            num_disp = numel(ID);
            
            % Default axes = gca
            if nargin < 4, axes_handle = gcf; end
            
            for i = 1:num_disp
                
                % obtain relevant highlight IDs (could be empty)
                fitID = category(ID(i)).fitID;
                trackID = category(ID(i)).trackID;
                % Get stackID
                if ~isempty(trackID), stackID = tracks.get_trackID(trackID(1)).stackID;
                else stackID = fits.get_fitID(fitID(1)).stackID; end
                
                % Get time (for graphing
                dev_time = cells.get_stackID(stackID).dev_time;
                dev_time = dev_time(~isnan(dev_time));
                
                % Extract fit/track of interest
                track = tracks.get_stackID(stackID); num_track = numel(track);
                fit = fits.get_stackID(stackID ); num_fit = numel(fit);
                
                % --- Plot tracked pulses ---
                % handle subplots, plot to alternative parent if applicable

                h(1) = subplot(3, num_disp, i, 'Parent', axes_handle);

%                 axes(h(1));
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

                h(2) = subplot(3, num_disp, num_disp + i, 'Parent', axes_handle);

%                 axes(h(2));
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
                h(3) = subplot(3, num_disp, 2*num_disp + i, 'Parent', axes_handle);
                
                cells.visualize( stackID, h(3) );
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
            
            if numel(pulse) > 1
                display(['Array of Pulse objects of size: [' num2str(size(pulse)) ']']);
                return
            end
            
            fprintf('\n')
            display('------ Tracked pulses ---------- ')
            display(['Total tracked pulses: ' num2str(numel(pulse.tracks))])
            display('------ Fitted pulses ----------- ')
            display(['Total fitted pulses: ' num2str(numel(pulse.fits))])
			display('------ Cells ------------------- ')
			display(['Total number of cells: ' num2str(numel(pulse.cells))])
			display(['Total tracked cells: ' ...
                num2str( numel(pulse.cells([pulse.cells.flag_tracked] == 1)) ) ]);
            display(['Total fitted cells: ' ...
                num2str( numel(pulse.cells([pulse.cells.flag_fitted] == 1)) ) ]);
            fprintf('\n')

            display('------ Matching ---------------- ')
			if isfield(pulse.categories,'one2one')
				num_one2one = numel( pulse.categories.one2one );
                foo = [pulse.categories.one2one.trackID];
                bar = find_one2one(pulse.map);
                bar = [bar.trackID];
                
%                 if any( ~ismember(foo,bar)), keyboard; end
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
        
    end % Dynamic methods
    
end
