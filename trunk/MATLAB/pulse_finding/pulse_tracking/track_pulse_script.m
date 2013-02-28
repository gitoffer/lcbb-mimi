%%TRACK_PULSE_SCRIPT Pipeline for

%% Load MDF into matrix

mdf_file = '~/Desktop/Tracked pulses/01-30-2012-4/01-30-2012-4-merged_acm.tif.mdf'; embryoID = 1;
% mdf_file = '~/Desktop/Tracked pulses/10-25-2012-1/10-25-2012-1-acm.mdf'; embryoID = 4;
% mdf_file = '~/Desktop/Tracked pulses/01-30-2012-7/01-30-2012-7_acm.mdf'; embryoID = 2;

mdf_mat = read_mdf(mdf_file);

tracks = load_mdf_track(mdf_mat, embryo_stack, embryoID, 1, cells);
fitsOI_ID = [fits( ismember([fits.stackID], [tracks.stackID]) ).fitID];
% filter_non_fitted_cells(tracks,pulses);

%% Perform matching to fitted pulses

clear pulse

for i = 1:1
    match_thresh = 1;
    
    pulse(i) = Pulse(tracks,mdf_file,fits,fitsOI_ID,fit_opts(embryoID));
    pulse(i) = pulse(i).match_pulse(match_thresh);
    pulse(i) = pulse(i).categorize_mapping;
    
    pulse(i).embryoID = embryoID;
    display(pulse(i));

end
