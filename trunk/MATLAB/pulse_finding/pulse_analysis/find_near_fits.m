% function [near_pulses,nearIDs] = find_near_pulses(pulses,pulseID,time_window,neighborIDs)
% %FIND_NEAR_PULSE
% 
% this_pulse = pulses(pulseID);
% same_embryo = pulses([pulses.embryoID] == this_pulse.embryoID);
% center_frame = this_pulse.margin_frames(floor(numel(this_pulse.margin_frames)/2));
% neighbor_cells = neighborIDs{center_frame,this_pulse.stackID};
% neighbor_cells = neighbor_cells(neighbor_cells > 0)';
% 
% count = 0;
% 
% for i = neighbor_cells
%     % Check for spatial neighbors
% %     if this_pulse.embryo == 5, keyboard; end
%     neighbor_pulses = find([same_embryo.cellID] == i);
%     if ~isempty(neighbor_pulses)
%         for j = neighbor_pulses
%             % Check for temporal nearness (of pulse centers)
%             if abs(pulses(j).center - this_pulse.center) < time_window
%                 count = count + 1;
%                 near_pulses(count) = pulses(j);
%                 nearIDs(count) = j;
%             end
%         end
%     end
% end
% 
% if ~exist('near_pulses','var'),near_pulses = []; nearIDs = []; end
% 
% end

function [nearby_fits,nearIDs] = find_near_fits(fits,time_window,neighborID)
%FIND_NEAR_FITS Find the number (and fitID) of each fitted pulse within an
% array of fitted pulses

num_fits = numel(fits);
nearby_fits = cell(1,num_fits);
nearIDs = cell(1,num_fits);

for i = 1:num_fits
    
    this_fit = fits(i);
    % Get fits in the same embryo
    same_embryo = fits( [fits.embryoID] == this_fit.embryoID );
    % Get the center frame of this pulse
    center_frame = fix( mean(this_fit.margin_frames) );
    % Get all neighboring cells
    neighbor_cells = neighborID{ center_frame , this_pulse.stackID};
    
    for j = neighbor_cells % j - neighbor cell's stackID
        
        % Find all neighboring fits
        neighbor_fits = same_embryo([same_embryo.cellID] == i);
        
        if ~isempty( neighbor_fits )
            % Collect fits within window
            within_window = [pulse.center] - this_fits.center < time_window;
            nearby_fits{j} = neighbor_fits(within_window);
            nearIDs{i} = [ neighbor_fits(within_window).fitID ];
            
        end
        
    end
    
end