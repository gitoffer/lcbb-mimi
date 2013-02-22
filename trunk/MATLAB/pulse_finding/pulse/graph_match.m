function graph_pulse_category(obj,cat,range,axis_handle)
%GRAPH_MERGED Visualize the merged pulses/tracks
%
%
% xies@mit.edu

num_merge = numel(range);

for i = 1:num_in_cat
    
    % Arrays of relevant track/pulses
    if isfield(merge,'fitID')
        fitID = merge(range(i)).fitID;
    else
        fitID = [];
    end
    
    if isfield(merge,'trackID')
        trackID = merge(range(i)).trackID;
    else
        trackID = [];
    end
    
    % Get stackID for this cell
    if ~isempty(trackID), stackID = track(trackID(1)).stackID;
    else stackID = fit(fitID(1)).stackID; end
    
    % Get its associated time
    dev_time = cells(stackID).dev_time;
    % Plot pulse + tracks
    
    g = plot_pulse_tracks(...
        fit( [fit.stackID] == stackID) ,...
        track( [track.stackID] == stackID) , ...
        dev_time, {trackID,fitID}, ...
        [3, num_merge, i, num_merge + i], ...
        handles);
    
%     axes(handles);
    subplot(3,num_merge, 2*num_merge + i);
    h = visualize_cell(cells, stackID);
    
    linkaxes([h g], 'x');
    
%     pulseIDs
    
end

end