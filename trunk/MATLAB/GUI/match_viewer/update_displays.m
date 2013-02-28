function handles = update_displays(handles)
% Used by MATCH_VIEWER - Update all the text displays

switch get(handles.fit,'Value')
    case 1
        which = 'fitID';
    case 0
        which = 'trackID';
end
this_pulse = handles.this_pulse;

set( handles.cellID_display,'String', ...
    num2str(handles.current_cell) );
set( handles.movie_pulse_display, 'String', ...
    [ which ': ' num2str(this_pulse.(which)) ] );
set(handles.current_frame,'String', ...
    [ 'Frame: ' num2str( (get(handles.slider2,'Value')) ) ] );

set(handles.trackID_display,'String', ...
    sprintf('%d\n', handles.current_tracks) );
set(handles.fitID_display,'String', ...
    sprintf('%d\n', handles.current_fits) );

end