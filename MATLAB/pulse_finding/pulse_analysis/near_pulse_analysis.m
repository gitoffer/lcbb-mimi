% wt_cutoff = find([pulse.embryo]<6,1,'last');
% pulseOI = pulse([pulse.pulseID] < wt_cutoff);
num_peaks = numel(fits);

time_windows = 5:5:30; %seconds
near_pulses = cell(6,num_peaks);
nearID = cell(6,num_peaks);
num_near = zeros(6,num_peaks);

for j = 1:6
    time_window = time_windows(j);
    
    [near_pulses{j,:},nearID{j,:}] = ...
        find_near_fits(fits,time_window,neighborID);
    %     near_pulses{i} = near;
    num_near(j,:) = cellfun(@numel,near_pulses(j,:));
    
end
