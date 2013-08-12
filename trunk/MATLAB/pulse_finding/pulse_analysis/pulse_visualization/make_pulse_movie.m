function F = make_pulse_movie(pulse,input,vx,vy)
%MAKE_PULSE_MOVIE Wrapper function for MAKE_CELL_IMG to make a movie of a
% single detected pulse, using the PULSE structure as returned by
% FIT_GAUSSIAN_PEAKS.
%
% USAGE: F = make_pulse_movie(pulse,input,vx,vy);
%
% SEE ALSO: MAKE_CELL_IMG
%
% xies@mit.edu

% embryoID = pulse.embryoID;

if isfield(pulse,'dev_frame'),pulse_frames = pulse.dev_frame;
else pulse_frames = pulse.margin_frames; end
h.vx = vx(pulse_frames,:);
h.vy = vy(pulse_frames,:);

h.sliceID = input.actual_z;

% h.frames2load = master_time(pulse_frames) + input.t0;
h.frames2load = pulse_frames;

h.cellID = pulse.cellID;
h.input = input;
h.channels = {'Membranes','Myosin'};

% If there is a '.curve' associated with the pulse, then put it down as the
% measurement to plot else, do not.
if isfield(pulse,'curve')
    h.measurement = pulse.curve;
end

h.border = 'on';

figure

F = make_cell_img(h);

end
