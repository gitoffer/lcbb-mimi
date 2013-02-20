function [found,overlap] = compare_pulse_identification(ref_pulse,comp_pulse,threshold)
%COMPARE_PULSE_IDENTIFICATION
%
% SYNOPSIS: found = compare_pulse_identification( ...
%               ref_pulse,comp_pulse,master_time,threshold);
%
% xies@mit.edu

num_pulse = numel(ref_pulse);

found = nan(1,num_pulse);
overlap = nan(1,num_pulse);

if isfield(ref_pulse,'width_frames'),ref_pulse_field = 'width_frames';
else ref_pulse_field = 'frame'; end

if isfield(comp_pulse,'width_frames'), comp_pulse_field = 'width_frames';
else comp_pulse_field = 'frame'; end

% if isfield(ref_pulse,'pulseID'),ref_ID_field = 'pulseID';
% else ref_ID_field = 'trackID'; end

if isfield(comp_pulse,'pulseID'),comp_ID_field = 'pulseID';
else comp_ID_field = 'trackID'; end

for i = 1:num_pulse
    
    this_pulse = ref_pulse(i);
    % Ignore cases where pulse was not IDed cases in the first place
    if isnan(this_pulse.cell), continue; end
    if numel(this_pulse.frame) < threshold + 1, keyboard; continue; end
    
    % Find candidate matches (pulses in the same cell)
    candidates = [comp_pulse([comp_pulse.cell] == this_pulse.cell)];
    
    % If there are no matches, continue to next track
%     if this_pulse.cell == 296, keyboard; end
    if isempty(candidates), found(i) = 0; continue; end
    
    found(i) = 0;
    overlaps = zeros(numel(candidates),1);
    for j = 1:numel(candidates)
        overlaps(j) = numel(intersect( ...
            getfield(candidates(j),comp_pulse_field), ...
            getfield(this_pulse,ref_pulse_field)));
    end
    
    [~,order] = sort(overlaps,1,'descend');
    
    if overlaps(order(1)) > threshold
        found(i) = getfield(candidates(order(1)),comp_ID_field);
        overlap(i) = overlaps(order(1));
    end
    
end

end