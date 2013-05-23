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
    this_pulse = tracks.get_trackID( cats.(current_cat)(catID).(which) (whichID) );
    frames = [this_pulse.dev_frame];
else
    % get all frames and bounds of non-nan frames
    this_pulse = fits.get_fitID( cats.(current_cat)(catID).(which) (whichID) );
    min_nan = find(~isnan( ...
        handles.pulse.cells.get_stackID(this_pulse.stackID).dev_time),1,'first');
    max_nan = find(~isnan( ...
        handles.pulse.cells.get_stackID(this_pulse.stackID).dev_time),1,'last');
    frames = [this_pulse.width_frames];
    frames = frames( frames >= min_nan & frames <= max_nan );
end

% Set slider boundaries
if max(frames) - min(frames) < 1
    set(handles.slider2,'Visible','off');
else
    set(handles.slider2,'Visible','on');
    set( handles.slider2,'Min', min(frames), 'Max', max(frames), ...
        'SliderStep', [1, 1]/(numel(frames) - 1) );
    if get(handles.slider2,'Value') < min(frames) || get(handles.slider2,'Value') > max(frames)
        set(handles.slider2,'Value',min(frames));
    end
end

% Update handle
handles.this_pulse = this_pulse;
handles.which = which;
handles.whichID_display = whichID;

% Update texts
handles = update_displays(handles);

% Gall grapher
handles = match_viewer_update_movie_callback(handles);

end