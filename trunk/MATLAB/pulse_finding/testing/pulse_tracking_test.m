%PULSE_TRACKING_TEST Test to see if the pulse tracked by hand are detected
% by the algorithm.

% tracks = read_mdf('~/Dropbox/Pulse tracking/01-30-2012-4/01-30-2012-4-mimi.mdf'); embryoID = 1;
% tracks = read_mdf('~/Dropbox/Pulse tracking/01-30-2012-4/01-30-2012-4-merged_acm.tif.mdf'); embryoID = 1;
% tracks = read_mdf('~/Dropbox/Pulse tracking/10-25-2012-1/10-25-2012-1-mimi.mdf'); embryoID = 4;
tracks = read_mdf('~/Dropbox/Pulse tracking/10-25-2012-1/10-25-2012-1-acm.mdf'); embryoID = 4;

embryo_stack = edge2embryo(EDGEstack);

tracked_pulse = load_mdf_pulse(tracks,embryo_stack(embryoID),input(embryoID), ...
    num_cells,master_time(embryoID));

cellOI = unique([tracked_pulse.cell]);
cellOI = cellOI(~isnan(cellOI));
cellOI = cellOI(~cellfun(@isempty,{cell_fits(cellOI).num_peaks}));
tracked_pulse = [tracked_pulse(ismember([tracked_pulse.cell],cellOI))];
for i = 1:numel(tracked_pulse)
    tracked_pulse(i).trackID = i;
end
pulseOI = [pulse(ismember([pulse.cell],cellOI))];

[found,overlaps] = compare_pulse_identification(tracked_pulse,pulseOI,1);
[rev_found,rev_overlaps] = compare_pulse_identification(pulseOI,tracked_pulse,1);

%% Pulse of interest is those found in tracked cells

num_match = numel(found(found > 0));
num_tracks = numel([tracked_pulse(~isnan([tracked_pulse.cell]))]);

merged_by_fit = find_merges(found);
for i = 1:numel(merged_by_fit)
    merged_by_fit(i).origin = [tracked_pulse(merged_by_fit(i).origin).trackID];
end
merged_by_tracking = find_merges(rev_found);
for i = 1:numel(merged_by_tracking)
    merged_by_tracking(i).origin = [pulseOI(merged_by_tracking(i).origin).pulseID];
end

missed_by_fit = tracked_pulse(find(found==0));
missed_by_tracking = pulse(find(rev_found==0));

% Display results in summary
display(['Total valid tracks found in manual tracking: ' num2str(num_tracks)]);

one_to_one = found(~ismember(found,unique([merged_by_fit.target merged_by_tracking.origin])));
one_to_one = numel(one_to_one(one_to_one > 0));
display(['One-to-one correspondence found: ' num2str(one_to_one)]);

num_missed_by_fit = numel(missed_by_fit);
display(['Tracked pulses missed by fitting: ' num2str(num_missed_by_fit)]);

% num_merged_by_fit = numel(merged_by_fit);
% display(['Groups of tracked pulses merged by fitting: ' num2str(num_merged_by_fit)]);
num_pulse_merged_by_fit = numel(unique([merged_by_fit.origin]));
display(['Tracked pulses merged by fitting: ' num2str(num_pulse_merged_by_fit)]);

num_pulse_merged_by_tracking = numel(unique([merged_by_tracking.target]));
display(['Tracked pulses split by fitting: ' num2str(num_pulse_merged_by_tracking)]);

num_missed_by_tracking = numel(missed_by_tracking);
display(['Number of pulses added by fitting: ' num2str(num_missed_by_tracking)]);

num_fitted = numel(pulseOI);
display(['Total relevant fitted pulses: ' num2str(num_fitted)]);

%% Pulse compare sa tracks

% cellID = randi(num_cells(1));
% cellID = 1;

% mergeID = 6;
% trackID = merged_by_fit(mergeID).origin
% pulseID = merged_by_fit(mergeID).target
% cellID = tracked_pulse(origin).cell;

figure;

for i = 1:5

    
    
    
%     missedID = i+15;
%     trackID = missed_by_fit(missedID).trackID;
%     missed_by_fit(missedID).mdfID
%     cellID = tracked_pulse(trackID).cell;
%     pulseID = [];
	
    g = plot_pulse_tracks([pulse([pulse.cell]==cellID)],...
        [tracked_pulse([tracked_pulse.cell]==cellID)], ...
        master_time,{pulseID,trackID},[3,5,i,5+i]);
    
    subplot(3,5,10+i);
    visualize_cell
    linkaxes([h,g],'x');
end

