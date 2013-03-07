% wt_cutoff = find([pulse.embryo]<6,1,'last');
% pulseOI = pulse([pulse.pulseID] < wt_cutoff);
num_peaks = numel(fits);

time_windows = 5:5:30; %seconds
near_pulses = cell(6,num_peaks);
nearID = cell(6,num_peaks);
num_near = zeros(6,num_peaks);

for j = 1:6
    time_window = time_windows(j);
    for i = 1:num_peaks
        [near_pulses{j,i},nearID{j,i}] = ...
            find_near_pulses(fits,i,time_window,neighborID);
        %     near_pulses{i} = near;
        num_near(j,i) = numel(near_pulses{j,i});
    end
    
end
