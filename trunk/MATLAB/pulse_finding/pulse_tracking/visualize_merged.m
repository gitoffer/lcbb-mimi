function visualize_merged(match,cells,track,pulse,startID)

merge = match.merge;
num_merge = min(numel(merge), 5);

for i = startID : startID + numel(merge) - 1
    % Arrays of relevant track/pulses
    pulseID = merge(i).pulseID;
    trackID = merge(i).trackID;
    
    % Get stackID for this cell
    stackID = track(trackID(i)).stackID;
    % Get its associated time
    dev_time = cells(stackID).dev_time;
    % Plot pulse + tracks
    g = plot_pulse_tracks(...
        pulse( [pulse.stackID] == stackID) ,...
        track( [track.stackID] == stackID) , ...
        dev_time, {pulseID,trackID}, ...
        [3, num_merge, i, num_merge + i] );
    
    subplot(3,num_merge, 2*num_merge + i);
    h = visualize_cell(cells, stackID);
    
    linkaxes([h g], 'x');
    
end