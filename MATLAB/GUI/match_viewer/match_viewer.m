function varargout = match_viewer(varargin)
% MATCH_VIEWER MATLAB code for match_viewer.fig
%      MATCH_VIEWER, by itself, creates a new MATCH_VIEWER or raises the existing
%      singleton*.
%
%      H = MATCH_VIEWER returns the handle to a new MATCH_VIEWER or the handle to
%      the existing singleton*.
%
%      MATCH_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATCH_VIEWER.M with the given input arguments.
%
%      MATCH_VIEWER('Property','Value',...) creates a new MATCH_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before match_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to match_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help match_viewer

% Last Modified by GUIDE v2.5 21-Feb-2013 20:15:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @match_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @match_viewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before match_viewer is made visible.
function match_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to match_viewer (see VARARGIN)

% Choose default command line output for match_viewer
handles.output = hObject;

% Get data
pulse = varargin{1}; handles.pulse = pulse;
categories = pulse.categories;

cells = varargin{2}; handles.cells = cells;
embryo_struct = varargin{3}; handles.embryo_struct = embryo_struct;

% Initialize category selector
cat_names = fieldnames(categories);
set(handles.category,'String', cat_names(end:-1:1));
set(handles.category,'Value',1);
set(handles.track_or_fit,'String', {'Track','Fit'});

handles = match_category_id_selector_callback(handles);

% categories = get(handles.category,'String');
% current_category = lower(categories{get(handles.category,'Value')});
% % ID
% set(handles.categoryID, ...
%     'String', num2cell(1:numel( match.(current_category) )) );
% set(handles.categoryID,'Value',1);
% categoryID = get(handles.categoryID,'Value');
% 
% graph_match(match.(current_category),cells,tracks,pulses,categoryID);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes match_viewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = match_viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in category.
function category_Callback(hObject, eventdata, handles)
% hObject    handle to category (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% match = handles.pulses.match;
% cells = handles.cells;
% 
% categories = get(hObject,'String');
% current_category = lower(categories{get(hObject,'Value')});
% % Set ID range
% set(handles.categoryID, ...
%     'String', num2cell(1:numel( match.(current_category) )) );
% set(handles.categoryID,'Value',1);
% categoryID = get(handles.categoryID,'Value');
% 
% graph_match(match.(current_category),cells,tracks,pulses,categoryID);

handles = match_category_id_selector_callback(handles);

guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns category contents as cell array
%        contents{get(hObject,'Value')} returns selected item from category


% --- Executes during object creation, after setting all properties.
function category_CreateFcn(hObject, eventdata, handles)
% hObject    handle to category (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in categoryID.
function categoryID_Callback(hObject, eventdata, handles)

% match = handles.match;
% cells = handles.cells;
% tracks = handles.tracks;
% pulses = handles.pulses;
% 
% categories = get(handles.category,'String');
% current_category = lower(categories{get(handles.category,'Value')});
% % ID
% catIDs = get(hObject, 'String');
% categoryID = catIDs{get(hObject,'Value')};
% categoryID = str2double(categoryID);
% 
% visualize_match(match.(current_category),cells,tracks,pulses,categoryID);
% handles=guidata(handles.output);

handles = match_category_id_selector_callback(handles);

guidata(hObject,handles);

% hObject    handle to categoryID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns categoryID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from categoryID


% --- Executes during object creation, after setting all properties.
function categoryID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to categoryID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -- Spawn pulse play_movie --;

% --- Executes on button press in play_movie.
function play_movie_Callback(hObject, eventdata, handles)
% hObject    handle to play_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data from handle
pulses = handles.pulses;
tracks = pulses.tracks; fits = pulses.fits;
match = pulses.match;
% cells = handles.cells; embryo_struct = handles.embryo_struct;

% get current selected category
categories = get(handles.category,'String');
current_category = lower(categories{get(handles.category,'Value')});
match = match.(current_category);
% catID
catID = get( handles.categoryID, 'Value' );

% track or fit?
which = get(handles.track_or_fit,'Value');
if which == 1, which = 'trackID'; else which = 'fitID'; end
% special case for add/miss
if strcmpi(current_category,'miss'), which = 'trackID'; end
if strcmpi(current_category,'add'), which = 'fitID'; end

pulseID = get(handles.pulseID,'Value');

if strcmpi(which, 'trackID')
    F = make_pulse_movie( ...
        tracks( match(catID).(which)(pulseID) ), ...
        handles.embryo_struct.input,...
        handles.embryo_struct.vertex_x,handles.embryo_struct.vertex_y,...
        handles.embryo_struct.dev_time);
else
    F = make_pulse_movie( ...
        fits( match(catID).(which)(pulseID) ), ...
        handles.embryo_struct.input,...
        handles.embryo_struct.vertex_x,handles.embryo_struct.vertex_y,...
        handles.embryo_struct.dev_time);
end

play_movie(F);

% --- Executes on selection change in track_or_fit.
function track_or_fit_Callback(hObject, eventdata, handles)
% hObject    handle to track_or_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns track_or_fit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from track_or_fit


% --- Executes during object creation, after setting all properties.
function track_or_fit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to track_or_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over play_movie.
function play_movie_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to play_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pulseID.
function pulseID_Callback(hObject, eventdata, handles)
% hObject    handle to pulseID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pulseID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pulseID


% --- Executes during object creation, after setting all properties.
function pulseID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulseID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
