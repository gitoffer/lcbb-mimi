function varargout = visualize_cluster(varargin)
%VISUALIZE_CLUSTER M-file for visualize_cluster.fig
%      VISUALIZE_CLUSTER, by itself, creates a new VISUALIZE_CLUSTER or raises the existing
%      singleton*.
%
%      H = VISUALIZE_CLUSTER returns the handle to a new VISUALIZE_CLUSTER or the handle to
%      the existing singleton*.
%
%      VISUALIZE_CLUSTER('Property','Value',...) creates a new VISUALIZE_CLUSTER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to visualize_cluster_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VISUALIZE_CLUSTER('CALLBACK') and VISUALIZE_CLUSTER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VISUALIZE_CLUSTER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualize_cluster

% Last Modified by GUIDE v2.5 28-Nov-2012 19:10:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualize_cluster_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_cluster_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before visualize_cluster is made visible.
function visualize_cluster_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

switch numel(varargin)
    case {0,1}
        error('Need an input dataset and cluster labels.');
    case 2
        set(handles.radiobutton2,'Enable','off');
    case 3
        mydata.clim = varargin{3};
        set(handles.radiobutton2,'Enable','off');
    case 4
        mydata.clim = varargin{3};
        mydata.secondary = varargin{4};
end

% get input data & sort it
mydata.primary = varargin{1}; mydata.labels = varargin{2};
mydata.num_clusters = numel(unique(mydata.labels));
[~,sortID] = sort(mydata.labels);
mydata.sorted_primary = mydata.primary(sortID,:);
if isfield(mydata,'secondary')
    mydata.sorted_secondary = mydata.secondary(sortID,:);
end

% Plot onto the heapmap
pcolor(handles.dataplotter,mydata.sorted_primary);
shading(handles.dataplotter,'flat'); colorbar('peer',handles.dataplotter);
if isfield(mydata,'clim'), caxis(handles.dataplotter,mydata.clim); end

% Initiate the cluster selecter
cluster_options = cell(1,mydata.num_clusters);
for i = 1:mydata.num_clusters
    cluster_options{i} = num2str(i);
end
set(handles.clusterselecter,'String',cluster_options);

handles.mydata = mydata;

% Choose default command line output for visualize_cluster
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

clusterselecter_Callback(handles.clusterselecter,eventdata,handles);


% UIWAIT makes visualize_cluster wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = visualize_cluster_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function dataplotter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataplotter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'FontSize',20);
% Hint: place code in OpeningFcn to populate dataplotter


% --- Executes on mouse press over axes background.
function dataplotter_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to dataplotter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in clusterselecter.
function selected_cluster = clusterselecter_Callback(hObject, eventdata, handles)
% hObject    handle to clusterselecter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
selected_cluster = str2num(contents{get(hObject,'Value')});

% Cluster heatmap - use pcolor if there are many traces, otherwise use
% PLOT
% Check which data: Primary or Secondary
switch get(handles.radiobutton1,'Value')
    case 1
        data = handles.mydata.primary;
    case 0
        data = handles.mydata.secondary;
end

if numel(handles.mydata.labels(handles.mydata.labels == selected_cluster)) > 1
    pcolor(handles.clusterplotter,...
        data(handles.mydata.labels == selected_cluster,:));
    shading(handles.clusterplotter,'flat');
    colorbar('peer',handles.clusterplotter);
    if isfield(handles.mydata,'clim') & get(handles.radiobutton1,'Value') == 1
        caxis(handles.clusterplotter,handles.mydata.clim);
    end
else
    plot(handles.clusterplotter,...
        data(handles.mydata.labels == selected_cluster,:));
end
% Mean and median
plot(handles.clustermeanplotter,...
    data(handles.mydata.labels == selected_cluster,:)');
hold(handles.clustermeanplotter,'on');

errorbar(handles.clustermeanplotter,...
    nanmean(data(handles.mydata.labels == selected_cluster,:),1),...
    nanstd(data(handles.mydata.labels == selected_cluster,:),[],1),'k-',...
    'LineWidth',2);
hold(handles.clustermeanplotter,'on');

plot(handles.clustermeanplotter,...
    nanmedian(data(handles.mydata.labels == selected_cluster,:),1),'r-',...
    'LineWidth',5);
hold(handles.clustermeanplotter,'off');


% Hints: contents = cellstr(get(hObject,'String')) returns clusterselecter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from clusterselecter


% --- Executes during object creation, after setting all properties.
function clusterselecter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterselecter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function clusterplotter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterplotter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'FontSize',20);
% Hint: place code in OpeningFcn to populate clusterplotter


% --- Executes during object creation, after setting all properties.
function clustermeanplotter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clustermeanplotter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'FontSize',20);
% Hint: place code in OpeningFcn to populate clustermeanplotter


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function dataselecter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataselecter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function radiobutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',1);

% --- Executes during object creation, after setting all properties.
function radiobutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);

% --- Executes when selected object is changed in dataselecter.
function dataselecter_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in dataselecter 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton1'
        % Code for when radiobutton1 is selected.
        pcolor(handles.dataplotter,handles.mydata.sorted_primary);
        shading(handles.dataplotter,'flat'); colorbar('peer',handles.dataplotter);
        if isfield(handles.mydata,'clim'), caxis(handles.dataplotter,handles.mydata.clim); end
    case 'radiobutton2'
        % Code for when radiobutton2 is selected.
        pcolor(handles.dataplotter,handles.mydata.sorted_secondary);
        shading(handles.dataplotter,'flat'); colorbar('peer',handles.dataplotter);
    otherwise
        % Code for when there is no match.
end
clusterselecter_Callback(handles.clusterselecter,eventdata,handles);
