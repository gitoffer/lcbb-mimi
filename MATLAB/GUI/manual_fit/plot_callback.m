function handles = plot_callback(handles)

this_cell = handles.this_cell;
if ~isfield(handles,'params')
    
    handles.center = handles.init_params(1);
    set(handles.center_display,'String',handles.center);
    handles.std = handles.init_params(2);
    set(handles.std_display,'String',handles.std);
    handles.frame = findnearest(this_cell.dev_time,handles.center);
    handles.frame = handles.frame(1);
    handles.amplitude = handles.this_cell.myosin_sm(handles.frame);
    set(handles.amplitude_display,'String',handles.amplitude);
    handles.offset = 100;
    set(handles.offset_display,'String',handles.offset);
    
end

handles.frame = findnearest(this_cell.dev_time,handles.center);
handles.frame = handles.frame(1);
handles.params = [handles.amplitude handles.center handles.std handles.offset];

% set limits
% set(handles.center_displ
% set(handles.center_display,'Min',nanmin(this_cell.myosin_sm), ...
%     'Max',nanmax(this_cell.myosin_sm),'Value',handles.center);
% set(handles.amplitude_display,'Min',0, ...
%     'Max',max(this_cell.myosin_sm),'Value',handles.amplitude);
% set(handles.std_display,'Min',10,'Max',50);

% % set values
% set(handles.center_slider,'Value',max(nanmin(this_cell.myosin_sm),handles.params(1)));
% set(handles.center_slider,'Value',max(nanmin(this_cell.myosin_sm),handles.params(1)));

% do the plotting
plot( handles.axes1, this_cell.dev_time, this_cell.myosin_intensity);
set( handles.axes1, 'Xlim', [nanmin(this_cell.fit_time) nanmax(this_cell.fit_time)] );

hold(handles.axes1,'on');

plot( handles.axes1, this_cell.fit_time, ...
    lsq_gauss1d_offset( handles.params, this_cell.fit_time ) ,'r-');

hold(handles.axes1,'off');

end