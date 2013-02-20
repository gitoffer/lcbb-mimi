function [map,overlaps] = match_pulse_track(ref,comp,threshold)
%MATCH_PULSE_TRACK Creates a Map container to encode the correspondence
% found between a reference_pulse object (pulse or track) and a
% comparison_pulse object.
%
% [map,overlaps] = match_pulse_track(pulse/track,pulse/trac,thresh2match)
% 
% See also: LOAD_MDF_TRACK, FIT_GAUSSIANS

% Import MAP class
import containers.Map;

% Validate inputs
if ~valid_input(ref,comp), error('Please enter PULSE or TRACK structures. See HELP.'); end

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


    function flag2cont = valid_input(ref,comp)
        flag2cont = isstruct(ref) && isstruct(comp);
    end

    function flag2cont = valid_pulse(ref,ref_field,thresh)
        flag2cont = ~any([isnan(ref.cellID) isnan(ref.embryoID) isnan(ref.stackID)]);
        flag2cont = flag2cont || numel(ref.(ref_field)) < thresh + 1; 
    end

    function [ref_field,comp_field,refID,compID] = get_pulse_fieldnames(ref,comp)
        if isfield(ref,'width_frames'),ref_field = 'width_frames';
        else ref_field = 'dev_frame'; end
        
        if isfield(comp,'width_frames'), comp_field = 'width_frames';
        else comp_field = 'dev_frame'; end
        
        if isfield(ref,'pulseID'),refID = 'pulseID';
        else refID = 'trackID'; end
        
        if isfield(comp,'pulseID'),compID = 'pulseID';
        else compID = 'trackID'; end
    end

end