classdef Track
    % TRACK Tracked pulses as imported from MTrackJ.
    properties (SetAccess = private)
        IDs % embryoID, stackID, cellID
        trackID
        pulseID
        developmental_timeframe
        image_timeframe
    end
    methods
        function track = Track(trackID,IDs,developmental_timeframe,image_timeframe)
            track.trackID = trackID;
            track.IDs = IDs;
            track.developmental_timeframe = developmental_timeframe;
            track.image_timeframe = image_timeframe;
        end % Constructor
        function tracks = match2pulse(tracks,pulses,theshold)
            num_tracks = numel(tracks);
            %         num_pulse = numel(pulses);
            
            found = nan(1,num_track);
            overlaps = nan(1,num_track);
            
            for i = 1:num_track
                
                % Extract single track
                this_track = tracks(i);
                % Ignore cases where track was not found in EDGEd cell in the
                % first place
                if isnan(this_track.cell), continue; end
                if numel(this_track.frame) < threshold + 1; keyboard; continue; end
                
                % Find the candidate matches (fitted pulse in same cell as
                % track)
                candidates = [pulses(pulses.
                
            end
            
        end
    end
    
end
