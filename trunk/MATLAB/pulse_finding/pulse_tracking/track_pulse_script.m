%%TRACK_PULSE_SCRIPT Pipeline for 

%% Load MDF into matrix
mdf_mat = read_mdf('~/Desktop/Tracked pulses/01-30-2012-4/01-30-2012-4-merged_acm.tif.mdf'); embryoID = 1;
% mdf_mat = read_mdf('~/Desktop/Tracked pulses/10-25-2012-1/10-25-2012-1-acm.mdf'); embryoID = 2;

tracks = load_mdf_track(mdf_mat, embryo_stack, embryoID, 1, cells);
pulseOI = [pulses( ismember([pulses.stackID], [tracks.stackID]) )];
% filter_non_fitted_cells(tracks,pulses);

%% Perform matching to fitted pulses

match_thresh = 1;

[mapTracksPulses,overlaps] = match_pulse_track(tracks,pulseOI,match_thresh);
[mapPulsesTracks,overlaps_rev] = match_pulse_track(pulseOI,tracks,match_thresh);

nbm = NonBijectiveMap(mapPulsesTracks,mapTracksPulses,'pulse','track');

match = categorize_mapping(nbm, pulseOI, tracks)

%% Visualize

visualize_merged.