classdef MatchTrackFit
    % A class to handle non-bijective mapping between two Map objects. Impelemented specifically
	% for Tracked pulses (TRACK) and Fitted pulses (FITTED)
    %
	% PROPERTIES dictTrackFit - A Map object (hashmap/dictionary) from tracked pulses to fitted pulses
	%			 dictFitTrack - The reverse map
	%
	% Note that neither mapping is necessarily unique or onto.
	%
	% METHODS:
	%	Constructor: obj = MatchTrackFit( track, fit, threshold_overlap )
	%	Merge: [obj,conflictTF, conflictFT] = Merge(obj1,obj2)
	%			Try to merge two objects. Return all conflicts.
	%	removeElement: obj = removeElement(obj, key (ID), name (track or fit)
	%	reassign: obj = reassibj(obj, trackID, fitID)
	%
    % See also: MAP, TRACK, FITTED, Pulse
    %
    % xies@mit.edu Feb 2013
    properties (SetAccess = private)
        dictTrackFit
        dictFitTrack
    end
    methods
        
        function obj = MatchTrackFit(track,fit,threshold)
            
            import containers.Map
            
            obj.dictTrackFit = match(track,fit,threshold);
            obj.dictFitTrack = match(fit,track,threshold);
            
            %-- Subfunction to take care of two-way matching
            function [map,overlaps] = match(ref,comp,threshold)
                %MATCH_PULSE_TRACK Creates a Map container to encode the correspondence
                % found between a reference_pulse object (pulse or track) and a
                % comparison_pulse object.
                %
                % [map,overlaps] = match_pulse_track(pulse/track,pulse/trac,thresh2match)
                %
                % See also: LOAD_MDF_TRACK, FIT_GAUSSIANS
                
                % Import MAP class
                import containers.Map;
                
                [ref_field,comp_field,refID,compID] = get_pulse_fieldnames(ref,comp);
                
                num_ref = numel(ref);
                overlaps = nan(1,numel(num_ref));
                % Initialize map object
                map = Map('keyType','double','valueType','double');
                
                for i = 1:num_ref
                    
                    this_ref = ref(i);
                    if ~valid_pulse(this_ref,ref_field,threshold), continue; end
                    
                    candidates = comp( [comp.stackID] == this_ref.stackID );
                    
                    if isempty(candidates), continue; end
                    
                    overlap = zeros(numel(candidates,1));
                    for j = 1:numel(candidates)
                        overlap(j) = numel(intersect ( ...
                            candidates(j).(comp_field), ...
                            this_ref.(ref_field) ));
                    end
                    
                    [~,order] = sort(overlap, 2, 'descend');
                    
                    if overlap( order(1) ) > threshold
                        % Add key-value pair (use unique IDs)
                        map(this_ref.(refID)) = ...
                            candidates(order(1)).(compID);
                        
                    end
                    
                    overlaps(i) = overlap( order(1) );
                end
                
                function flag2cont = valid_pulse(ref,ref_field,thresh)
                    flag2cont = ~any([isnan(ref.cellID) isnan(ref.embryoID) isnan(ref.stackID)]);
                    flag2cont = flag2cont || numel(ref.(ref_field)) < thresh + 1;
                end
                
                function [ref_field,comp_field,refID,compID] = get_pulse_fieldnames(ref,comp)
                    if strcmp(class(ref),'Fitted'),ref_field = 'width_frames';
                    else ref_field = 'dev_frame'; end
                    
                    if strcmp(class(comp),'Fitted'),comp_field = 'width_frames';
                    else comp_field = 'dev_frame'; end
                    
                    if strcmp(class(ref),'Fitted'),refID = 'fitID';
                    else refID = 'trackID'; end
                    
                    if strcmp(class(comp),'Fitted'),compID = 'fitID';
                    else compID = 'trackID'; end
                end
                % ---- End sub-nested functions
            end % End subfunction
            
        end % constructor
        
        function [obj,conflictTF,conflictFT] = Merge(obj,obj2)
            %Merge two map objects (aka when there is a new value in either
            %tracks or fits
			%
			% USAGE: [merged_obj, conflictTF, conflictFT] = ...
			%				Merge( obj1,obj2 )
			%
			% A conflict occurs if a key in Map2 exists also in Map1, creating two
			%	conflicting mappings between the value in Map1 and the new value in
			%	Map2. This key/val pair is set aside and returned as a conflicted item.
			%
			% xies@mit.edu
            
            [mergedTF,conflictTF] = merge_maps(obj.dictTrackFit,obj2.dictTrackFit);
            [mergedFT,conflictFT] = merge_maps(obj.dictFitTrack,obj2.dictFitTrack);
            
            obj.dictTrackFit = mergedTF;
            obj.dictFitTrack = mergedFT;
            
            % --- Merge in map
            function [map,conflict] = merge_maps(map,map2)
                keylist = map2.keys;
                conflict = Map('KeyType','double','VType','double');
                for i = 1:numel(keylist)
                    if map.isKey(keylist{i})
                        conflict(keylist{i}) = map2(keylist{i});
                        continue
                    end
                    map(keylist{i}) = map2(keylist{i});
                end
            end % Merge/merge_maps
            
        end % Merge
        
        function obj = removeElement(obj,key,name)
            % Removes a Pulse object from the two maps
            switch name
                case 'track'
                    mapname = 'dictTrackFit'; othername = 'dictFitTrack';
                case 'fit'
                    mapname = 'dictFitTrack'; othername = 'dictTrackFit';
            end
            
            if isKey(obj.(mapname),key), obj.(mapname).remove(key); end
            
            vlist = obj.(othername).values;
            if ~ismember( key, [vlist{:}] ), return; end
            keylist = obj.(othername).keys;
            obj.(othername).remove( ...
                num2cell( keylist{cellfun(@(x) x == key,vlist)} ) );
            
        end %removeElement

        function obj = reassign(obj,trackID,fitID)
            % Reassign a TRACK to a FIT, only suceeds if both are 'unattached'
            keyTrackID = obj.dictTrackFit.keys;
            valFitID = obj.dictTrackFit.values;
            keyFitID = obj.dictFitTrack.keys;
            valTrackID = obj.dictFitTrack.values;
            
            if (~any( ...
                    cellfun(@(x) (x == trackID), keyTrackID) | ...
                    cellfun(@(x) (x == fitID), valFitID) ) || ...
                    ~any( ...
                    cellfun(@(x) (x == fitID), keyFitID) | ...
                    cellfun(@(x) (x == trackID), valTrackID)))

                    obj.dictTrackFit(trackID) = fitID;
                    obj.dictFitTrack(fitID) = trackID;
            else
                display('FitID already assigned.')
            end
        end % reassign
        
    end %methods
    
end %classdef
