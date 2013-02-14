function h = plot_pulse_tracks(pulse1,pulse2,master_time,varargin)
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

if unique([pulse1.cell]) ~= unique([pulse2.cell])
    error('Please enter pulses found in the same cell.')
end

% Highlight tracks if given
if nargin > 3, ID = varargin{1}; highlight = 1; end
if nargin > 4, subplot_arg = varargin{2}; else subplot_arg = [3 1 1]; end
master_time = master_time(pulse2(1).embryoID);

% First plot
h(1) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(3));
num_pulse1 = numel(pulse1);
binary_trace = concatenate_pulses(pulse1,master_time.aligned_time);
if highlight && ~isempty(ID{1})
    on = highlight_track(pulse1,ID{1});
    binary_trace(on,:) = binary_trace(on,:) + 3;
end
if num_pulse1 > 1
    imagesc(master_time.aligned_time,1:num_pulse1,binary_trace);
elseif num_pulse1 == 1
    plot(master_time.aligned_time,binary_trace);
end
set(gca,'Xlim',[min(master_time.aligned_time) max(master_time.aligned_time)]);
title(['Fitting'])
xlabel('Time (sec)')

% Second plot
h(2) = subplot(subplot_arg(1),subplot_arg(2),subplot_arg(4));
num_pulse2 = numel(pulse2);
binary_trace = concatenate_pulses(pulse2,master_time.aligned_time);
if highlight && ~isempty(ID{2})
    on = highlight_track(pulse2,ID{2});
    binary_trace(on,:) = binary_trace(on,:) + 3;
end

if num_pulse2 > 1
    imagesc(master_time.aligned_time,1:num_pulse2,binary_trace);
elseif num_pulse2 == 1
    plot(master_time.aligned_time,binary_trace);
end
title('Manual')
xlabel('Time (sec)')
set(gca,'Xlim',[min(master_time.aligned_time) max(master_time.aligned_time)]);

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