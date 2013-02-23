function [fits,time] = align_peaks(fits,measurement,name,opt)
%ALIGN_PEAKS Aligns the global maxima of a given set of time-series
% traces. Will return also a given measurement aligned according to the
% maxima. Updates the fits structure.
%
% SYNOPSIS: [fits,time] = align_peaks(fitss,cells,opt);
%
% xies@mit.edu Aug 2012

num_fits = numel(fits);
durations = cellfun('length',{fits.margin_frames});
% max_duration = max(durations);

l = opt(1).left_margin; r = opt(1).right_margin;

% aligned_p = nan(num_peaks,l + r + 1);
% aligned_m = nan(num_peaks,l + r + 1);
time = nan(num_fits,l + r + 1);
center_idx = l + 1;

for i = 1:num_peaks
    
    % Extract single peak
	this_fit_curve = fits(i).fit;
	num_nonan_frames = numel(this_fit);
	[~,max_idx] = max(this_peak);
		
	left_len = max_idx - 1;

	time(i, ...
		(center_idx - left_len) : (center_idx - left_len + this_duration - 1)) ...
		= fits(i).aligned_time;

%    this_fit = fits(i).fit_padded;
%    this_fit = this_peak(~isnan(this_peak));
%    this_duration = durations(i);
    %     num_frames = numel(this_peak);
%    [~,max_idx] = max(this_peak);
    
%    left_len = max_idx - 1;
    %     right_len = this_duration-max_idx;
    
    %     aligned_p(i, ...
    %         (center_idx - left_len):(center_idx - left_len + this_duration - 1)) ...
    %         = this_peak;
    
%    time(i, ...
%        (center_idx - left_len):(center_idx - left_len + this_duration - 1)) ...
%        = pulses(i).aligned_time;
    
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
