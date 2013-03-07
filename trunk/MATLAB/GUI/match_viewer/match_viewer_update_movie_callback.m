function handles = match_viewer_update_movie_callback(handles)

this_pulse = handles.this_pulse;

h.vx = handles.embryo_struct.vertex_x; h.vy = handles.embryo_struct.vertex_y;
h.cellID = this_pulse.cellID;
h.input = handles.embryo_struct.input;
h.channels = {'Membranes','Myosin'};
h.border = 'on';
% h.dev_frame = handles.embryo_struct.dev_frame;

h.axes = handles.movie_axes;

cla(h.axes);
set(h.axes,'XTick',[],'YTick',[]);

% Find slider frame
selected_frame = get(handles.slider2,'Value');
h.frames2load = selected_frame;
handles.frame = selected_frame;

% Update texts
set( handles.current_frame,'String',num2str( get(handles.slider2,'Value') ) );

make_cell_img(h);

end