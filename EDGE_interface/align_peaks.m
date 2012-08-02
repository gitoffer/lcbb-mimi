function [aligned_p,varargout] = align_peaks(peaks,locations,cellIDs,measurement)

if nargin > 1, other_measurement = 1;
else other_measurement = 0; end

% [num_frames,num_cells] = size(peaks);
num_peaks = numel(peaks);

durations = cellfun('length',peaks);
max_duration = max(durations);

aligned_p = nan(num_peaks,2*max_duration + 1);
aligned_m = nan(num_peaks,2*max_duration + 1);
center_idx = max_duration + 1;

for i = 1:num_peaks
    this_peak = peaks{i};
    this_duration = durations(i);
    num_frames = numel(this_peak);
    [~,max_idx] = max(this_peak);
    
%     keyboard
    left_len = max_idx - 1;
%     right_len = this_duration-max_idx;
    
    aligned_p(i, ...
        (center_idx - left_len):(center_idx - left_len + this_duration - 1)) ...
        = this_peak;
    if other_measurement
        aligned_m(i, ...
            (center_idx - left_len):(center_idx - left_len + this_duration - 1)) ...
            = measurement(locations{i},cellIDs(i));
    end
end

%     function left = get_left_idx(~,mark)
%         if mark > 1
%             left = 1:mark;
%         else
%             left = [];
%         end
%     end
%     function right = get_right_idx(len,mark)
%         if mark < len
%             right = (mark + 1):len;
%         else
%             right = [];
%         end
%     end

if other_measurement
    varargout{1} = aligned_m;
end

end