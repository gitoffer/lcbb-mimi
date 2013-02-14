function F = make_pulse_movie(pulse,input,vx,vy,master_time)
%MAKE_PULSE_MOVIE Wrapper function for MAKE_CELL_IMG to make a movie of a
% single detected pulse, using the PULSE structure as returned by
% FIT_GAUSSIAN_PEAKS.
%
% USAGE: F = make_pulse_movie(pulse,input,vx,vy,master_time);
%
% SEE ALSO: MAKE_CELL_IMG
%
% xies@mit.edu

embryoID = pulse.embryoID;

pulse_frames = pulse.frame;
h.vx = vx(pulse_frames,:);
h.vy = vy(pulse_frames,:);

h.sliceID = input(embryoID).actual_z;

h.frames2load = master_time(embryoID).frame(pulse_frames) + input(embryoID).t0;

h.cellID = pulse.cell;
h.input = input(embryoID);
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
