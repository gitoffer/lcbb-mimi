%%Visualize_pulse

%% Make movies of individual pulses

% F = make_pulse_movie(fits(101),input,vertices_x,vertices_y,dev_time);
F = fits.movie(101,embryo_stack,cells);
play_movie(F)

%% Make a movie of hand-tracked pulse

G = make_pulse_movie(tracked_pulse(196),input,vertices_x,vertices_y,master_time);

%%
% save movie (to appropriate folder)
% if strcmpi(in(1).folder2load,input_twist(1).folder2load)
%     if ids(cellID).which == 1, var_name = '006'; else var_name = '022'; end
%     movie2avi(f,['~/desktop/edge processed/twist ' var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% elseif strcmpi(in(1).folder2load,input(1).folder2load)
%     if ids(cellID).which == 1, var_name = '4'; else var_name = '7'; end
%     movie2avi(f,['~/desktop/edge processed/embryo '  var_name '/pulse_movies/pulse_' num2str(pulseID)]);
% end

% %% Plot individual pulses
% 
% ID = 217;
% 
% figure
% nonantime = pulse(ID).width_frames;
% frame = master_time(pulse(ID).embryoID).frame(pulse(ID).width_frames)
% time = master_time(pulse(ID).embryoID).aligned_time(pulse(ID).width_frames);
% 
% center = pulse(ID).center;
% 
% plotyy(time,myosins_sm(nonantime,pulse(ID).cell),...
%     time,areas_sm(nonantime,pulse(ID).cell));
% hold on
% % plot(cell_fits(pulse(ID).cell).time,cell_fits(pulse(ID).cell).bg,'r-')
% 
% %% Plot MTracJ pulses
% 
% mjID = 280;
% 
% figure,
% 
% frame = tracked_pulse(mjID).frame;
% time = master_time(tracked_pulse(mjID).embryoID).aligned_time(frame);
% 
% plotyy(time,myosins_sm(frame,tracked_pulse(mjID).cell),...
%     time,areas_sm(frame,tracked_pulse(mjID).cell));
