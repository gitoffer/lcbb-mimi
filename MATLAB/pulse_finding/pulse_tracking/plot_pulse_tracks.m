function h = plot_pulse_tracks(pulse1,pulse2,dev_time,varargin)
%PLOT_PULSE_TRACKS
% 
% USAGE: plot_pulse_tracks(pulse1,pulse2,master_time);
%        plot_pulse_tracks(pulse1,pulse2,master_time,highlight);
%
% INPUT: pulse1 - tracked/fitted
%        pulse2 - tracked/fitted
%        master_time - the entire array
%        highlight - pulseID/trackID to highlight. cell array.
%
% xies@mit.edu

if unique([pulse1.stackID]) ~= unique([pulse2.stackID])
    error('Please enter tracks and pulses found in the same cell.')
end

% Highlight tracks if given
if nargin > 3, ID = varargin{1}; highlight = 1; end
if nargin > 4, subplot_arg = varargin{2}; else subplot_arg = [3 1 1]; end
dev_time = dev_time(pulse2(1).embryoID);

% Parse inputs
[track,pulse] = which_is_which(pulse1,pulse2);

% --- Plot tracked pulses ---
h(1) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(3)); % If 
num_track = numel(track);
% Create a binary track
binary_trace = concatenate_pulses(track,dev_time.aligned_time);
% Highlight if applicable
if highlight && ~isempty(ID{1})
    on = highlight_track(pulse1,ID{1});
    binary_trace(on,:) = binary_trace(on,:) + 3;
end
% If there are things to plot...
if num_track > 1
    imagesc(master_time.aligned_time,1:num_pulse1,binary_trace);
elseif num_pulse1 == 1
    plot(master_time.aligned_time,binary_trace);
end
set(gca,'Xlim',[min(master_time.aligned_time) max(master_time.aligned_time)]);
xlabel('Time (sec)')
title(['Manual: cell ' num2str(pulse1.stackID)])

% -- Plot fitted pulses --
h(2) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(4));
num_pulse = numel(pulse);
% Create a binary track
binary_trace = concatenate_pulses(pulse2,master_time.aligned_time);
% Highlight if applicable
if highlight && ~isempty(ID{2})
    on = highlight_track(pulse2,ID{2});
    binary_trace(on,:) = binary_trace(on,:) + 3;
end
if num_pulse > 1
    imagesc(master_time.aligned_time,1:num_pulse2,binary_trace);
elseif num_pulse2 == 1
    plot(master_time.aligned_time,binary_trace);
end
title('Fit')
xlabel('Time (sec)')
set(gca,'Xlim',[min(master_time.aligned_time) max(master_time.aligned_time)]);

    % Parse inputs to find which input is the pulse and which the track
    function [track,pulse] = which_is_which(pulse1,pulse2)
        if isfield(pulse1,'pulseID')
            pulse = pulse1; track = pulse2;
        else
            pulse = pulse2; track = pulse1;
        end
    end

    % Creates a binary track of all pulses
    function binary = concatenate_pulses(pulse,time)
        binary = zeros(numel(pulse),numel(time));
        if isfield(pulse,'width_frames'), frames = {pulse.width_frames};
        else frames = {pulse.frame}; end
        for i = 1:numel(pulse)
            binary(i,frames{i}) = 1;
        end
    end


    % Parse the ID field and match the correct pulse to highlight
    function on = highlight_track(pulse,ID)
        if isfield(pulse,'pulseID'),
            on = ismember([pulse.pulseID],ID);
        else
            on = ismember([pulse.trackID],ID);
        end
    end

end