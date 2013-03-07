classdef Track
	%TRACK Tracked pulses loaded from a MDF file as output from MTrackJ
	% and cross-checked against EDGE cells
	%
	% Properties:
	%	embryoID - the embryo index
	%	cellID - EDGE cellID
	%	stackID - stacked index of all cells
	% 	mdfID - the original mdfID
	%	dev_frame
	% 	dev_time
	%	img_frame
	%
	% 	trackID - unique index
	% 	category - matching category to FITTED
	%	manually_added - flag for artificially added tracks
	%
	
    properties (SetAccess = private)

        embryoID % which embryo in stack
        cellID	% EDGE ID for cell
        stackID % index in cell stack
        mdfID 	% Original track index from MtrackJ
        
        dev_frame % The active track frames in aligned frame
        dev_time  % The developmental aligned time for track
        
    end
    
    properties (SetAccess = public)
        
        trackID		% trackID (not same as mdfID)
        category 	% category of match to FITTED
        manually_added % Whether it's manually added or not
        
    end
    
    methods (Access = public)
        
        function obj = Track(this_track)
            % TRACK constructor. Use from LOAD_MDF_TRACK
            if nargin > 0
                names = fieldnames(this_track);
                for i = 1:numel(names)
                    [obj.(names{i})] = deal(this_track.(names{i}));
                    obj.manually_added = 0;
                end
            end
        end % constructor
% --------------------- Search methods -----------------------------------
        function objs = get_trackID(obj_array,trackID)
            % search for and return the TRACKs with the given trackID(s)
            objs = obj_array( ismember([obj_array.trackID],trackID) );
        end %get_trackID
        
        function objs = get_stackID(obj_array,stackID)
            % search for and return the TRACKs with the given trackID(s)
            objs = obj_array( ismember([obj_array.stackID],stackID) );
        end %get_stackID
        
% --------------------- Comparator ---------------------------------------   
        function equality = eq(track1,track2)
            % Equality comparator for TRACK
            % right now slow, expecting array
            if numel(track1) > 1 && numel(track2) > 1
                error('Cannot handle TWO array inputs.');
            end
            names = setdiff(fieldnames(track2),{'trackID','category','mdfID'});
            equality = false(1,numel(track1));
            for j = 1:numel(track1)
                % can't use bsxfun because of un-uniform output
                eqs = 1;
                for i = 1:numel(names)
                    % if dim don't match, then not equal
                    if numel(track1(j).(names{i})) ~= numel(track2.(names{i}))
                        eqs = 0;
                        break;
                    else
                        eqs = eqs && ...
                            all(eq( nonans(track1(j).(names{i})), nonans(track2.(names{i})) ));
                    end
                end
                equality(j) = eqs;
            end
            
        end
    end
    
    methods
% --------------------- Array operations ---------------------------------
        function obj_array = add_track(obj_array,new_track)
            % Check for previously existing
            % We're sure it's a new track
            new_track.mdfID = NaN;
            new_track.trackID = max([obj_array.trackID]) + 1;
            new_track = Track(new_track);
            new_track.manually_added = 1;
            
            if any(obj_array == new_track)
                disp('Cannot create new track: Track already exists.');
                return
            end
            
            obj_array = [obj_array new_track];
        end
        
    end

%--------------------------- Unit tests ---------------------------------%
%     methods (Access = private)
%         
%         % Constructor test
%         function flag2cont = valid_object(obj)
%             flag2cont = all( ~ismember( ...
%                 fieldnames(obj), properties(Track)) );
%         end %valid_object
%         
%     end

    
end
