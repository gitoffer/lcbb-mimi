function handles = match_category_id_selecter_callback(handles)
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

if numel( pulse.categories.(current_cat) ) == 0
    
    
    
else
    if get( handles.categoryID,'Value') > numel(pulse.categories.(current_cat))
        set(handles.categoryID,'Value',1);
        handles.display_graph = 1;
    end
end
catID = get( handles.categoryID,'Value');



if strcmpi(current_cat,'add')
    set(handles.fit,'Enable','off');
    set(handles.track,'Enable','off');
    set(handles.fit,'Value',1);
    set(handles.track,'Value',0);
elseif strcmpi(current_cat,'miss')
    set(handles.fit,'Enable','off');
    set(handles.track,'Enable','off');
    set(handles.fit,'Value',0);
    set(handles.track,'Value',1);
else
    set(handles.fit,'Enable','on');
    set(handles.track,'Enable','on');
end

handles.catID = catID;
handles.current_category = current_cat;

pulse.graph(current_cat,cells,catID,handles.axes_panel);

end