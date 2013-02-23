function handles = movie_pulse_selecter_callback(handles)
% USED by MATCH_VIEWER - graphs the current pulse at the given frame

% get data
pulse = handles.pulse; cats = pulse.categories;
fits = pulse.fits; tracks = pulse.tracks;

% get category, catID
current_cat = handles.current_category; catID = handles.catID;

% get track/fit selecter
which = get(handles.track,'Value');
if which == 1, which = 'trackID'; else which = 'fitID'; end
handles.which = which;
% set whichID to its max allowed vlaue
set( handles.whichID, ...
    'String', num2cell( 1:numel(cats.(current_cat)(catID).(which)) ) );
if get(handles.whichID,'Value') > numel(cats.(current_cat)(catID).(which))
    set(handles.whichID,'Value',1);
end
whichID = get(handles.whichID,'Value');

% get current_pulse according to which/whichID
if strcmpi( which,'trackID' )
    this_pulse = tracks( cats.(current_cat)(catID).(which) (whichID) );
    frames = [this_pulse.dev_frame];
else
    this_pulse = fits.get_fitID( cats.(current_cat)(catID).(which) (whichID) );
    frames = [this_pulse.width_frames];
end

% Set slider boundaries
set( handles.slider2,'Min', min(frames), 'Max', max(frames), ...
    'SliderStep', [1, 1]/(numel(frames) - 1) );
if get(handles.slider2,'Value') < min(frames) || get(handles.slider2,'Value') > max(frames)
    set(handles.slider2,'Value',min(frames));
end

% Update texts
set( handles.pulseID,'String', ...
    [which ': ' num2str(this_pulse.(which)) ] );
set( handles.current_frame, 'String', ...
    ['Frame: ' num2str( get(handles.slider2,'Value') )] );


% Update handle
handles.this_pulse = this_pulse;


% Gall grapher
handles = match_viewer_update_movie_callback(handles);

end