function loadgui(arg,w)
% LOADBUI  Load Data GUI
%
% This GUI function loads data for the EDA series of GUIs. If data have
% already been loaded, then a warning will be issued that you are about to
% replace your existing data set.
%
% One can also load up optional information using this GUI. This includes
% labels for the observations (case names), labels for the variables, and
% class labels. 
%
% This GUI can be accessed from every GUI, using the Load Data button found
% in the upper left corner of every GUI.
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       loadgui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','loadgui');
if isempty(flg)
    % then create the gui
    loadlayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'datafile')
    % then load data from the file
    datafile
elseif strcmp(arg,'dataws')
    % then load data from the workspace
    % w is a string containing variables in main workspace
    dataws(w)
elseif strcmp(arg,'caselabfile')
    % then load case labels from a file
    caselabfile
elseif strcmp(arg,'caselabws')
    % then load case labels from the workspace
    caselabws(w) 
elseif strcmp(arg,'varlabfile')
    % then load variable labels from a file
    varlabfile
elseif strcmp(arg,'varlabws')
    % then load variable labels from the workspace
    varlabws(w)
elseif strcmp(arg,'classlabfile')
    % then load class labels from a file
    classlabfile
elseif strcmp(arg,'classlabws')
    % then load class labels from the workspace
    classlabws(w)
elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
   tg = findobj('tag','loadgui');
   delete(tg)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function datafile
% assume this is a text file only with one variable. If user wants to
% import a .mat file, then they should just load in the workspace and load
% that way.
ud = get(0,'userdata');
% Check to see if something exists there already. Provide a warning that
% they are about to overwrite their data.
if ~isempty(ud.X)
    ButtonName=questdlg('Overwrite existing data set?', ...
        'Load Data Warning','Yes','No','No');
    if strcmp(ButtonName,'No')
        % Then escape from this.
        return
    end
end
% Reset the structure.
ud = userdata;
set(0,'userdata',ud)
% Reset the popupmenu data strings for the GUIs.
tg = findobj('tag','gedagui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
tg = findobj('tag','agcgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
tg = findobj('tag','mbcgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
tg = findobj('tag','kmeansgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
[filename, pathname] = uigetfile({'*.txt';'*.*'}, 'Pick a file');
if filename ~= 0
    % user did not press cancel.
    data = load([pathname filename]);
    % check to see if a mat file
    if isstruct(data)
        errordlg('You are trying to load a .mat file. Load the .mat file into the workspace using the Command Line. Then use the GUI to load from the workspace.','Loading Error')
        return
    end
    % reset the fields with the loading information.
    ud.loadfile = [pathname filename];
    ud.loadworkspace = [];
    % Fill up the User Data structure.
    ud.X = data;
    [n,p] = size(ud.X);
    if n == 1 | p == 1
        errordlg('You must have more than 1 dimension to use these GUIs.')
        return
    end
    % Set up the default case labels: 1:n as a cell array of strings.
    % Set up the default variable labels: 1:p as a cell array of strings.
    ud.caselab = cell(1,n);
    ud.varlab = cell(1,p);
    for i = 1:n
        ud.caselab{i} = int2str(i);
    end
    for i = 1:p
        ud.varlab{i} =  int2str(i);
    end
    
    set(0,'userdata',ud)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataws(w)
if isempty(w)
    errordlg('You do not have any variables in the workspace.')
    return
end
% Check to see if something exists there already. Provide a warning that
% they are about to overwrite their data.
ud = get(0,'userdata');
if ~isempty(ud.X)
    ButtonName=questdlg('Overwrite existing data set?', ...
        'Load Data Warning','Yes','No','No');
    if strcmp(ButtonName,'No')
        % Then escape from this.
        return
    end
end
% Reset the structure.
ud = userdata;
set(0,'userdata',ud)
% Reset the popupmenu data strings for the GUIs.
tg = findobj('tag','gedagui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
tg = findobj('tag','agcgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
tg = findobj('tag','mbcgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
tg = findobj('tag','kmeansgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',ud.dimred)
end
[choice,ok] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString',w);
if ok ~= 0
    % then user selected something
    str = ['ud = get(0,''userdata'');' 'ud.X = ' w{choice} ';' 'set(0,''userdata'',ud)'];
    evalin('base',str)
    % Load the data from the workspace.
    ud = get(0,'userdata');
    ud.loadfile = [];
    ud.loadworkspace = w{choice};
    [n,p] = size(ud.X);
    if n == 1 | p == 1
        errordlg('You must have more than 1 dimension to use these GUIs.')
        return
    end
    % Set up the default case labels: 1:n as a cell array of strings.
    % Set up the default variable labels: 1:p as a cell array of strings.
    ud.caselab = cell(1,n);
    ud.varlab = cell(1,p);
    for i = 1:n
        ud.caselab{i} = int2str(i);
    end
    for i = 1:p
        ud.varlab{i} =  int2str(i);
    end
    set(0,'userdata',ud)
else
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function caselabfile
% Load up labels for observations - OPTIONAL
% assume this is a text file only with one variable. If user wants to
% import a .mat file, then they should just load in the workspace and load
% that way.
ud = get(0,'userdata');
[filename, pathname] = uigetfile({'*.txt';'*.*'}, 'Pick a file');
if filename ~= 0
    % user did not press cancel.
    data = load([pathname filename]);
    % check to see if a mat file
    if isstruct(data)
        errordlg('You are trying to load a .mat file. Load the .mat file into the workspace using the Command Line. Then use the GUI to load from the workspace.','Loading Error')
        return
    end
    % Do an error check. The length of the caselabel vector.
    [n,p] = size(ud.X);
    [nc, np] = size(data);
    if nc ~= 1 & np ~= 1
        errordlg('The data used for case labels must be a vector.')
        return
    end
    if n ~= length(data)
        errordlg('The number of case labels must match the number of data points - n.')
        return
    end
    % Replace the case label values in the User Data structure.
    ud.caselab = data;
    set(0,'userdata',ud)
else
    return
end
% Check to see if the brush/link GUI is open. If so, update the strings for
% the case label list box.
Hbgui = findobj('tag','brushgui');
if ~isempty(Hbgui)
    % then the gui is open.
    H = get(Hbgui,'userdata');
    set(H.listcase,'string',ud.caselab)    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function caselabws(w) 
% Load the data from the workspace.
if isempty(w)
    errordlg('You do not have any variables in the workspace.')
    return
end
[choice,ok] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString',w);
if ok ~= 0
    % then user selected something
    str = ['ud = get(0,''userdata'');' 'ud.tmp = ' w{choice} ';' 'set(0,''userdata'',ud)'];
    evalin('base',str)
    ud = get(0,'userdata');
    % Do an error check. The length of the caselabel vector.
    [n,p] = size(ud.X);
    [nc, np] = size(ud.tmp);
    if ~isnumeric(ud.tmp) & ~iscell(ud.tmp)
        % First it has to be numeric or a cell array.
        errordlg('The vector must be of type double or a cell array of strings.')
        return
    end
    if iscell(ud.tmp) & ~ischar(ud.tmp{1})
        errordlg('If it is a cell array, then it must be a cell array of strings.')
        return
    end  % checking to see if it is a cell array of strings
    if nc ~= 1 & np ~= 1
        errordlg('The data used for case labels must be a vector.')
        return
    end
    if n ~= length(ud.tmp)
        errordlg('The number of case labels must match the number of data points - n.')
        return
    end
    
    ud.caselab = ud.tmp;
    set(0,'userdata',ud)
else
    return
end
% Check to see if the brush/link GUI is open. If so, update the strings for
% the case label list box.
Hbgui = findobj('tag','brushgui');
if ~isempty(Hbgui)
    % then the gui is open.
    H = get(Hbgui,'userdata');
    set(H.listcase,'string',ud.caselab)    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varlabfile
% Load up labels for variable names - OPTIONAL
% assume this is a text file only with one variable. If user wants to
% import a .mat file, then they should just load in the workspace and load
% that way.
ud = get(0,'userdata');
[filename, pathname] = uigetfile({'*.txt';'*.*'}, 'Pick a file');
if filename ~= 0
    % user did not press cancel.
    data = load([pathname filename]);
    % check to see if a mat file
    if isstruct(data)
        errordlg('You are trying to load a .mat file. Load the .mat file into the workspace using the Command Line. Then use the GUI to load from the workspace.','Loading Error')
        return
    end
    % Do an error check. The length of the caselabel vector.
    [n,p] = size(ud.X);
    [nc, np] = size(data);
    if nc ~= 1 & np ~= 1
        errordlg('The data used for variable labels must be a vector.')
        return
    end
    if p ~= length(data)
        errordlg('The number of variable labels must match the number of variables p.')
        return
    end
    % Replace the case label values in the User Data structure.
    ud.varlab = data;
    set(0,'userdata',ud)
else
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5    
function varlabws(w)
% Load the data from the workspace.
if isempty(w)
    errordlg('You do not have any variables in the workspace.')
    return
end
[choice,ok] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString',w);
if ok ~= 0
    % then user selected something
    str = ['ud = get(0,''userdata'');' 'ud.tmp = ' w{choice} ';' 'set(0,''userdata'',ud)'];
    evalin('base',str)
    ud = get(0,'userdata');
    % Do an error check. The length of the caselabel vector.
    [n,p] = size(ud.X);
    [nc, np] = size(ud.tmp);
    if ~isnumeric(ud.tmp) & ~iscell(ud.tmp)
        % First it has to be numeric or a cell array.
        errordlg('The vector must be of type double or a cell array of strings.')
        return
    end
    if iscell(ud.tmp) & ~ischar(ud.tmp{1})
        errordlg('If it is a cell array, then it must be a cell array of strings.')
        return
    end  % checking to see if it is a cell array of strings
    if nc ~= 1 & np ~= 1
        errordlg('The data used for variable labels must be a vector.')
        return
    end
    if p ~= length(ud.tmp)
        errordlg('The number of variable labels must match the number of variables p.')
        return
    end
    ud.varlab = ud.tmp;
    set(0,'userdata',ud)
else
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classlabfile
% Load up labels for observations - OPTIONAL
% assume this is a text file only with one variable. If user wants to
% import a .mat file, then they should just load in the workspace and load
% that way.
ud = get(0,'userdata');
[filename, pathname] = uigetfile({'*.txt';'*.*'}, 'Pick a file');
if filename ~= 0
    % user did not press cancel.
    data = load([pathname filename]);
    % check to see if a mat file
    if isstruct(data)
        errordlg('You are trying to load a .mat file. Load the .mat file into the workspace using the Command Line. Then use the GUI to load from the workspace.','Loading Error')
        return
    end
    % Do an error check. The length of the caselabel vector.
    [n,p] = size(ud.X);
    [nc, np] = size(data);
    if nc ~= 1 & np ~= 1
        errordlg('The data used for class/group labels must be a vector.')
        return
    end
    if n ~= length(data)
        errordlg('The number of class/group labels must match the number of data points - n.')
        return
    end
    % Replace the case label values in the User Data structure.
    ud.classlab = data;
    set(0,'userdata',ud)
else
    return
end
% Check to see if the brush/link GUI is open. If so, update the strings for
% the case label list box.
Hbgui = findobj('tag','brushgui');
if ~isempty(Hbgui)
    % then the gui is open.
    H = get(Hbgui,'userdata');
    set(H.listgroup,'string',unique(ud.classlab))    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classlabws(w)
% Load the data from the workspace.
if isempty(w)
    errordlg('You do not have any variables in the workspace.')
    return
end
[choice,ok] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString',w);
if ok ~= 0
    % then user selected something
    str = ['ud = get(0,''userdata'');' 'ud.tmp = ' w{choice} ';' 'set(0,''userdata'',ud)'];
    evalin('base',str)
    ud = get(0,'userdata');
    % Do an error check. The length of the caselabel vector.
    [n,p] = size(ud.X);
    [nc, np] = size(ud.tmp);
    if ~isnumeric(ud.tmp) & ~iscell(ud.tmp)
        % First it has to be numeric or a cell array.
        errordlg('The vector must be of type double or a cell array of strings.')
        return
    end
    if iscell(ud.tmp) & ~ischar(ud.tmp{1})
        errordlg('If it is a cell array, then it must be a cell array of strings.')
        return
    end  % checking to see if it is a cell array of strings
    if nc ~= 1 & np ~= 1
        errordlg('The data used for class/group labels must be a vector.')
        return
    end
    if n ~= length(ud.tmp)
        errordlg('The number of class/group labels must match the number of data points - n.')
        return
    end
    
    ud.classlab = ud.tmp;
    set(0,'userdata',ud)
else
    return
end
% Check to see if the brush/link GUI is open. If so, update the strings for
% the case label list box.
Hbgui = findobj('tag','brushgui');
if ~isempty(Hbgui)
    % then the gui is open.
    H = get(Hbgui,'userdata');
    set(H.listgroup,'string',unique(ud.classlab))    
end

