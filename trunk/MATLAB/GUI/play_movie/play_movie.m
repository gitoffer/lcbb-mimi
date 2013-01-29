function varargout = play_movie(varargin)
% PLAY_MOVIE MATLAB code for play_movie.fig
%      PLAY_MOVIE, by itself, creates a new PLAY_MOVIE or raises the existing
%      singleton*.
%
%      H = PLAY_MOVIE returns the handle to a new PLAY_MOVIE or the handle to
%      the existing singleton*.
%
%      PLAY_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAY_MOVIE.M with the given input arguments.
%
%      PLAY_MOVIE('Property','Value',...) creates a new PLAY_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before play_movie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to play_movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help play_movie

% Last Modified by GUIDE v2.5 14-Sep-2012 19:17:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @play_movie_OpeningFcn, ...
                   'gui_OutputFcn',  @play_movie_OutputFcn, ...
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


% --- Executes just before play_movie is made visible.
function play_movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to play_movie (see VARARGIN)

% Choose default command line output for play_movie
handles.output = hObject;

if numel(varargin) ~= 1
    error('ERROR: Need movie as input!');
end
handles.movie = varargin{1};

num_frames = numel(handles.movie);

set(handles.slider1,'Min',1,...
    'Max',num_frames,...
    'Value',1, ...
    'SliderStep',[1 1]/(num_frames-1) ...
    );
%     'sliderstep',1);

current_frame = get(handles.slider1,'Value');
set(handles.edit1,'String',int2str(current_frame));

set(handles.edit1,'Value',current_frame);
imshow(handles.movie(current_frame).cdata,'Parent',get(handles.figure1,'CurrentAxes'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes play_movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = play_movie_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

current_frame = fix(get(hObject,'Value'));

set(handles.edit1,'String',int2str(current_frame));
set(handles.slider1,'Value',current_frame);

imshow(handles.movie(current_frame).cdata,'Parent',get(handles.figure1,'CurrentAxes'));

guidata(hObject, handles);


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% Text showing current frame

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_frame = str2num(get(hObject,'String'));
set(handles.edit1,'String',current_frame);
set(handles.slider1,'Value',current_frame);
imshow(handles.movie(current_frame).cdata,'Parent',get(handles.figure1,'CurrentAxes'));
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in playbutton.
function playbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
movie(get(handles.figure1,'CurrentAxes'),handles.movie);


% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
