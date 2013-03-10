%%TRACK_PULSE_SCRIPT Pipeline for

%% Load MDF into matrix

mdf_file = '~/Desktop/Tracked pulses/01-30-2012-4/01-30-2012-4-merged_acm.tif.mdf'; embryoID = 1;
% mdf_file = '~/Desktop/Tracked pulses/01-30-2012-7/01-30-2012-7_acm.mdf'; embryoID = 2;
% mdf_file = '~/Desktop/Tracked pulses/10-15-2012-1/10-15-2012-1.mdf'; embryoID = 3;
% mdf_file = '~/Desktop/Tracked pulses/10-25-2012-1/10-25-2012-1-acm.mdf'; embryoID = 4;
% mdf_file = '~/Desktop/Tracked pulses/11-07-2012-1/11-07-2012-1_acm.mdf'; embryoID = 5;

mdf_mat = read_mdf(mdf_file);

[tracks,cells] = load_mdf_track(mdf_mat, embryo_stack, embryoID, 1, cells);

%% Perform matching to fitted pulses

for i = 1:1
    match_thresh = 1;
    
    pulse(i) = Pulse(tracks,mdf_file,fits,fit_opts(embryoID),cells);
    pulse(i) = pulse(i).match_pulse(match_thresh);
    pulse(i) = pulse(i).categorize_mapping;
    
    pulse(i).embryoID = embryoID;
    display(pulse(i));

end
