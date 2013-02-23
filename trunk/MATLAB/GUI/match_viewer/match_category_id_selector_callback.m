function handles = match_category_id_selector_callback(handles)
% This function handles plotting the correct category/categoryID
% pulse/track onto the GUI axes

% handles=guidata(handles.output);

% Get data
pulse = handles.pulse;
cells = handles.cells;
% embryo_struct = handles.embryo_struct;
% fits = handles.pulse.fits;
% tracks = handles.pulse.tracks;

% Get the currently selected category
categories = get( handles.category,'String');
current_cat = lower( categories{get(handles.category,'Value')} );
set( handles.categoryID, ...
    'String', num2cell( 1:numel(pulse.categories.(current_cat)) ) );
catID = get( handles.categoryID,'Value');

if strcmpi(current_cat,'add')
    set(handles.track_or_fit,'Enable','off');
    set(handles.track_or_fit,'Value',2);
elseif strcmpi(current_cat,'miss')
    set(handles.track_or_fit,'Enable','off');
    set(handles.track_or_fit,'Value',1);
else
    set(handles.track_or_fit,'Enable','on');
end

pulse.graph(current_cat,cells,catID,handles.axes_panel);

end