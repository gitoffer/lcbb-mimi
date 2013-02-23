%%TRACK_PULSE_SCRIPT Pipeline for 

%% Load MDF into matrix
% mdf_mat = read_mdf('~/Desktop/Tracked pulses/01-30-2012-4/01-30-2012-4-merged_acm.tif.mdf'); embryoID = 1;
mdf_mat = read_mdf('~/Desktop/Tracked pulses/10-25-2012-1/10-25-2012-1-acm.mdf'); embryoID = 2;

tracks = load_mdf_track(mdf_mat, embryo_stack, embryoID, 1, cells);
fitsOI = [fits( ismember([fits.stackID], [tracks.stackID]) )];
% filter_non_fitted_cells(tracks,pulses);

%% Perform matching to fitted pulses
clear pulse
% match_thresh = 1;

% [mapTracksFits,overlaps] = match_pulse_track(tracks,fitsOI,match_thresh);
% [mapFitsTracks,overlaps_rev] = match_pulse_track(fitsOI,tracks,match_thresh);
% 
% nbm = NonBijectiveMap(mapTracksFits,mapFitsTracks,'track','fit');
match_thresh = 1;

pulse = Pulse(tracks,fitsOI);
pulse = pulse.match_pulse(match_thresh);
pulse = pulse.categorize_mapping;

pulse.embryoID = embryoID;

display(pulse);

%% Mannually-correct

% pulse
remove_list = [56 202];
createTF_list = [4 141 79 123 113 222 221 207 205 203];

for i = 1:numel(remove_list)
    pulse = pulse.removePulse( 'fit',remove_list(i) );
end

for i = 1:numel(createTF_list)
    pulse = pulse.createTrackFromFit( createTF_list(i) );
end
% pulse
