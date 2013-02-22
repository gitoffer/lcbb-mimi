function h = plot_pulse_tracks(pulse1,pulse2,dev_time,ID,subplot_arg,handles)
%PLOT_PULSE_TRACKS
%
% USAGE: plot_pulse_tracks(pulse1,pulse2,master_time,highlight);
%        plot_pulse_tracks(pulse1,pulse2,master_time,highlight,subplots);
%
% INPUT: pulse1 - tracked/fitted
%        pulse2 - tracked/fitted
%        master_time - the entire array
%        highlight - fitID/trackID to highlight. cell array.
%
% xies@mit.edu

if unique([pulse1.stackID]) ~= unique([pulse2.stackID])
    error('Please enter tracks and pulses found in the same cell.')
end

% Specific subplot pattern
if nargin < 4, subplot_arg = [3 1 1]; end

% Parse inputs
[track,fit] = which_is_which(pulse1,pulse2);

% --- Plot tracked pulses ---
% If Specified within GUI
if nargin > 4,
    h(1) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(3),...
        'Parent',handles);
else
    h(1) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(3));
end
num_track = numel(track);
% Create a binary track
binary_trace = concatenate_pulses(track,dev_time);
% Highlight if applicable
if ~isempty(ID{1})
    on = highlight_track(track,ID{1});
    binary_trace(on,:) = binary_trace(on,:) + 3;
end
% If there are things to plot...
if num_track > 1
    
    imagesc(dev_time,1:num_track,binary_trace);
    
elseif num_track == 1
    
    plot(dev_time,binary_trace);
    
else
    cla
end
set(gca,'Xlim',[min(dev_time) max(dev_time)]);
xlabel('Time (sec)')
title(['Manual: cell ' num2str(track(1).stackID)])

% -- Plot fitted pulses --
% If Specified within GUI
if nargin > 4,
    h(1) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(4),...
        'Parent',handles);
else
    h(1) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(4));
end
num_pulse = numel(fit);
% Create a binary track
binary_trace = concatenate_pulses(fit,dev_time);
% Highlight if applicable
if ~isempty(ID{2})
    on = highlight_track(fit,ID{2});
    binary_trace(on,:) = binary_trace(on,:) + 3;
end
if num_pulse > 1
    
    imagesc(dev_time,1:num_pulse,binary_trace);
    
elseif num_pulse == 1
    
    plot(dev_time,binary_trace);
    
else
    cla
end
title('Fit')
xlabel('Time (sec)')
set(gca,'Xlim',[min(dev_time) max(dev_time)]);

% -- Subfunctions -- %

% Parse inputs to find which input is the fit and which the track
    function [track,fit] = which_is_which(pulse1,pulse2)
        if strcmp(class(pulse1),'Fitted')
            fit = pulse1; track = pulse2;
        else
            fit = pulse2; track = pulse1;
        end
    end

% Creates a binary track of all pulses
    function binary = concatenate_pulses(pulse,time)
        binary = zeros(numel(pulse),numel(time));
        if strcmp(class(pulse),'Fitted'), frames = {pulse.width_frames};
        else frames = {pulse.dev_frame}; end
        for i = 1:numel(pulse)
            binary(i,frames{i}) = 1;
        end
    end


% Parse the ID field and match the correct pulse to highlight
    function on = highlight_track(pulse,ID)
        if strcmp(class(pulse),'Fitted')
            on = ismember([pulse.fitID],ID);
        else
            on = ismember([pulse.trackID],ID);
        end
    end

end