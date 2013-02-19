function [pulses,time] = align_peaks(pulses,measurement,name,opt)
%ALIGN_PEAKS Aligns the global maxima of a given set of time-series
%traces. Will return also a given measurement aligned according to the
%maxima.
%
% SYNOPSIS: [time,aligned_p,aligned_areas] =
%                align_peaks(pulses,myosins_sm,areas_sm,opt);
%
% xies@mit.edu Aug 2012


num_peaks = numel(pulses);
durations = cellfun('length',{pulses.margin_frames});
% max_duration = max(durations);

l = opt(1).left_margin; r = opt(1).right_margin;

% aligned_p = nan(num_peaks,l + r + 1);
% aligned_m = nan(num_peaks,l + r + 1);
time = nan(num_peaks,l + r + 1);
center_idx = l + 1;

for i = 1:num_peaks
    
    % Extract single peak
    this_peak = pulses(i).fit_padded;
    this_peak = this_peak(~isnan(this_peak));
    this_duration = durations(i);
    %     num_frames = numel(this_peak);
    [~,max_idx] = max(this_peak);
    
    left_len = max_idx - 1;
    %     right_len = this_duration-max_idx;
    
    %     aligned_p(i, ...
    %         (center_idx - left_len):(center_idx - left_len + this_duration - 1)) ...
    %         = this_peak;
    
    time(i, ...
        (center_idx - left_len):(center_idx - left_len + this_duration - 1)) ...
        = pulses(i).aligned_time;
    
    frames = nan(1, l + r + 1);
    
    frames( (center_idx - left_len) : (center_idx - left_len + this_duration - 1) ) = ...
        measurement( pulses(i).margin_frames, pulses(i).stackID );
    
    pulses(i).(name) = frames;
    
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

end