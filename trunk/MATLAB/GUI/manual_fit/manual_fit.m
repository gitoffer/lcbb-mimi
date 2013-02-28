function varargout = manual_fit(varargin)
% MANUAL_FIT MATLAB code for manual_fit.fig
%      MANUAL_FIT, by itself, creates a new MANUAL_FIT or raises the existing
%      singleton*.
%
%      H = MANUAL_FIT returns the handle to a new MANUAL_FIT or the handle to
%      the existing singleton*.
%
%      MANUAL_FIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUAL_FIT.M with the given input arguments.
%
%      MANUAL_FIT('Property','Value',...) creates a new MANUAL_FIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manual_fit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manual_fit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manual_fit

% Last Modified by GUIDE v2.5 26-Feb-2013 17:15:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manual_fit_OpeningFcn, ...
                   'gui_OutputFcn',  @manual_fit_OutputFcn, ...
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


% --- Executes just before manual_fit is made visible.
function manual_fit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manual_fit (see VARARGIN)

% Choose default command line output for manual_fit
handles.output = hObject;

handles.init_params = varargin{1};
cells = varargin{2}; stackID = varargin{3};
handles.this_cell = cells([cells.stackID] == stackID);

handles = plot_callback(handles);
% plot( handles.axes1, this_cell.dev_time, this_cell.myosin_sm );

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manual_fit wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manual_fit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.params;
delete(handles.figure1);


function amplitude_display_Callback(hObject, eventdata, handles)
% hObject    handle to amplitude_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.amplitude = str2double(get(hObject,'String'));
handles = plot_callback(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of amplitude_display as text
%        str2double(get(hObject,'String')) returns contents of amplitude_display as a double


% --- Executes during object creation, after setting all properties.
function amplitude_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplitude_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function center_display_Callback(hObject, eventdata, handles)
% hObject    handle to center_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.center = str2double(get(hObject,'String'));
handles = plot_callback(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of center_display as text
%        str2double(get(hObject,'String')) returns contents of center_display as a double


% --- Executes during object creation, after setting all properties.
function center_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to center_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function std_display_Callback(hObject, eventdata, handles)
% hObject    handle to std_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.std = str2double(get(hObject,'String'));
handles = plot_callback(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of std_display as text
%        str2double(get(hObject,'String')) returns contents of std_display as a double


% --- Executes during object creation, after setting all properties.
function std_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to std_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume();


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, use UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
