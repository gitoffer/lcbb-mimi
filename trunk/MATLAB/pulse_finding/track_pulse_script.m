%%TRACK_PULSE_SCRIPT Pipeline for

%%

mdf_file{1} = '~/Desktop/Tracked pulses/01-30-2012-4/01-30-2012-4-merged_acm.tif.mdf'; embryoID(1) = 1;
mdf_file{2} = '~/Desktop/Tracked pulses/01-30-2012-7/01-30-2012-7_acm.mdf'; embryoID(2) = 2;
mdf_file{3} = '~/Desktop/Tracked pulses/10-15-2012-1/10-15-2012-1.mdf'; embryoID(3) = 3;
mdf_file{4} = '~/Desktop/Tracked pulses/10-25-2012-1/10-25-2012-1-acm.mdf'; embryoID(4) = 4;
mdf_file{5} = '~/Desktop/Tracked pulses/11-07-2012-1/11-07-2012-1_acm.mdf'; embryoID(5) = 5;
mdf_file{6} = '~/Desktop/Tracked pulses/Twist injection series 006/twist_series_006_mimi.mdf'; embryoID(6) = 6;
embryoID(7) = 7;
mdf_file{8} = '~/Desktop/Tracked pulses/11-10-2012-3/11-10-2012-3_mimi.mdf'; embryoID(8) = 8;

match_thresh = 1;

for i = 8
    
    % Load MDF into matrix
    mdf_mat = read_mdf(mdf_file{i});
    [tracks,cells] = load_mdf_track(mdf_mat, embryo_stack, embryoID(i), 1, cells);

    % Perform matching to fitted pulses
    
    pulse(i) = Pulse(tracks,mdf_file{i},fits_raw,fit_opts(embryoID),cells);
    pulse(i) = pulse(i).match_pulse(match_thresh);
    pulse(i) = pulse(i).categorize_mapping;
    
    pulse(i).embryoID = embryoID(i);
    display(pulse(i));

end
