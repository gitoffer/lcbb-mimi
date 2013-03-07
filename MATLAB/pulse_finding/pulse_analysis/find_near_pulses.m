function [near_pulses,nearIDs] = find_near_pulses(pulses,pulseID,time_window,neighborIDs)
%FIND_NEAR_PULSE

this_pulse = pulses(pulseID);
same_embryo = pulses([pulses.embryoID] == this_pulse.embryoID);
center_frame = this_pulse.margin_frames(floor(numel(this_pulse.margin_frames)/2));
neighbor_cells = neighborIDs{center_frame,this_pulse.stackID};
neighbor_cells = neighbor_cells(neighbor_cells > 0)';

count = 0;

for i = neighbor_cells
    % Check for spatial neighbors
%     if this_pulse.embryo == 5, keyboard; end
    neighbor_pulses = find([same_embryo.cellID] == i);
    if ~isempty(neighbor_pulses)
        for j = neighbor_pulses
            % Check for temporal nearness (of pulse centers)
            if abs(pulses(j).center - this_pulse.center) < time_window
                count = count + 1;
                near_pulses(count) = pulses(j);
                nearIDs(count) = j;
            end
        end
    end
end

if ~exist('near_pulses','var'),near_pulses = []; nearIDs = []; end

end