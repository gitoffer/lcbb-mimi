function F = make_pulse_movie(pulse,input,vx,vy,master_time)
% Wrapper function to make a movie of a single detected pulse

embryoID = pulse.embryo;

pulse_frames = pulse.frame;
h.vx = vx(pulse_frames,:);
h.vy = vy(pulse_frames,:);

h.sliceID = input(embryoID).actual_z;

h.frames2load = master_time(embryoID).frame(pulse_frames) + input(embryoID).t0;

h.cellID = pulse.cell;
h.input = input(embryoID);
h.channels = {'Membranes','Myosin'};
h.measurement = pulse.curve;
h.border = 'on';

figure

F = make_cell_img(h);

end
