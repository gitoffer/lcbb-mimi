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

% Last Modified by GUIDE v2.5 03-Dec-2012 12:26:33

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

% Parse inputs
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

% Figure out if the cluster input is a linkage map or a cluster label
if isvector(varargin{2})
    mydata.labels = varargin{2};
    % Disable dendrogram if no linkage is input
%     set(handles.dendrogram,'Visible','off');
    set(handles.threshold,'Visible','off');
    set(handles.clustering_threshold_text,'Visible','off');
    set(handles.text7,'Visible','off');
    [mydata.sortedLabels,mydata.sortID] = sort(mydata.labels);
    plot(handles.dendrogram,mydata.labels(mydata.sortID));
    set(handles.dendrogram,'CameraUpVector',[1 0 0]);
    set(handles.dendrogram,'XLim',[1 numel(mydata.sortID)]);
    set(handles.dendrogram,'YTick',[]);
else
    % If an input is linkage, then need to set threshold
    mydata.linkage = varargin{2};
    th = max(mydata.linkage(:,3))/2;
    set(handles.threshold,'String',th);
    % Plot dendrogram
    axes(handles.dendrogram);
    [~,~,mydata.sortID] = dendrogram(mydata.linkage,0,'colorthreshold',th,...
        'orientation','left');
    mydata.labels = cluster(mydata.linkage,'Cutoff',th,...
        'Criterion','distance');
    mydata.sortedLabels = mydata.labels(mydata.sortID);
    [ticks,ticklabels] = make_cluster_ticklabels(mydata.labels,mydata.sortID);
    % Turn off labels on dendrogram
    set(handles.dendrogram,'YTick',ticks);
    set(handles.dendrogram,'YTickLabel',ticklabels);
%     set(handles.dendrogram,'YDir','reverse');
end

% get input data & sort
mydata.primary = varargin{1};
mydata.num_clusters = max(mydata.labels(~isnan(mydata.labels)));
mydata.sorted_primary = mydata.primary(mydata.sortID,:);
if isfield(mydata,'secondary')
    mydata.sorted_secondary = mydata.secondary(mydata.sortID,:);
end

% Plot onto the central heatmap
pcolor(handles.dataplotter,mydata.sorted_primary);
set(handles.dataplotter,'YTickLabels',{});
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


% --- Outputs from this function are returned to the command line.
function varargout = visualize_cluster_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


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
        data = handles.mydata.sorted_primary;
    case 0
        data = handles.mydata.sorted_secondary;
end

new_order = handles.mydata.sortedLabels == selected_cluster;
if numel(handles.mydata.sortedLabels(new_order)) > 1
    pcolor(handles.clusterplotter,...
        data(new_order,:));
    shading(handles.clusterplotter,'flat');
    colorbar('peer',handles.clusterplotter);
    if isfield(handles.mydata,'clim') && get(handles.radiobutton1,'Value') == 1
        caxis(handles.clusterplotter,handles.mydata.clim);
    end
else
    plot(handles.clusterplotter,...
        data(new_order,:));
end
% Mean and median
plot(handles.clustermeanplotter,...
    data(new_order,:)');
hold(handles.clustermeanplotter,'on');

errorbar(handles.clustermeanplotter,...
    nanmean(data(new_order,:),1),...
    nanstd(data(new_order,:),[],1),'k-',...
    'LineWidth',2);
hold(handles.clustermeanplotter,'on');

plot(handles.clustermeanplotter,...
    nanmedian(data(new_order,:),1),'r-',...
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


% --- Executes during object creation, after setting all properties.
function dendrogram_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dendrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate dendrogram


% --- Executes during object deletion, before destroying properties.
function dendrogram_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to dendrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input = get(hObject,'String');
[input,success] = str2num(input);
% Check for valid input
if ~success, msgbox('Cluster threshold needs to numeric','Cluster threshold error');
else
    % Update cluster structure via mydata
    axes(handles.dendrogram);
    handles.mydata.threshold = input;
    [~,~,handles.mydata.sortID] = dendrogram(handles.mydata.linkage,0,...
        'colorthreshold',input,...
        'orientation','left');
    handles.mydata.labels = cluster(handles.mydata.linkage,'cutoff',input,...
        'Criterion','distance');
    % Re-sort according to new order
    handles.mydata.sortedLabels = handles.mydata.labels(handles.mydata.sortID);
    handles.mydata.sorted_primary = handles.mydata.primary(handles.mydata.sortID,:);
    if isfield(handles.mydata,'secondary')
        handles.mydata.sorted_secondary = handles.mydata.secondary(handles.mydata.sortID,:);
    end
%     handle.mydata.labels = parse_dendrogram_handles(H);
    handles.mydata.num_clusters = numel(unique( ...
        handles.mydata.labels(~isnan(handles.mydata.labels))));
    [ticks,ticklabels] = make_cluster_ticklabels(handles.mydata.labels,...
        handles.mydata.sortID);
    % Turn off labels on dendrogram
    set(handles.dendrogram,'YTick',ticks);
    set(handles.dendrogram,'YTickLabel',ticklabels);
%     set(handles.dendrogram,'YDir','reverse');
    
    % Initiate the cluster selecter
    cluster_options = cell(1,handles.mydata.num_clusters);
    for i = 1:handles.mydata.num_clusters
        cluster_options{i} = num2str(i);
    end
    set(handles.clusterselecter,'String',cluster_options);
    current_selection = get(handles.clusterselecter,'Value');
    set(handles.clusterselecter,'Value',min(current_selection,handles.mydata.num_clusters));
    
end

guidata(hObject, handles);
clusterselecter_Callback(handles.clusterselecter,eventdata,handles);

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double

% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [ticks,labels] = make_cluster_ticklabels(cluster_labels,sortedID)

cluster_order = unique_nosort(cluster_labels(sortedID));
num_clusters = numel(unique_nosort(cluster_labels));
num_members = zeros(1,num_clusters);
labels = cell(1,num_clusters);
for i = 1:num_clusters
    num_members(i) = numel(cluster_labels(cluster_labels == cluster_order(i)));
    labels{i} = num2str(cluster_order(i));
end
half_ways = floor(num_members/2);
ticks = cumsum(num_members) - half_ways;

% ticks = numel(cluster_labels)-cumsum(num_members);
% ticks = ticks(end:-1:1);
% half_ways = floor(num_members/2);
% ticks = ticks + half_ways(end:-1:1);
