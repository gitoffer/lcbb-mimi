function mdsgui(arg,typ)
% MDSGUI   Multi-dimensional Scaling GUI
%
% This GUI function drives the Multi-Dimensional Scaling methods. These
% include Classical MDS and Metric MDS. 
%
% MDS seeks to find a representation of the data in a lower-dimensional
% space such that observations that are close toghether in full dimensions
% are also close together in the lower-dimensional space. 
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       mdsgui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','mdsgui');
if isempty(flg)
    % then create the gui
    mdslayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'docmds')
    % Start the Classical MDS process.
    docmds
    
elseif strcmp(arg,'domds')
    % Do the Metric and Non-metric MDS procedures.
    domds   
    
elseif strcmp(arg,'geda')
    % Bring up the graphical EDA GUI
    gedagui
    % Added the following, Sep 14
    tg = findobj('Tag','gedagui');
    H = get(tg,'userdata');  % To reference H.data
    ud = get(0,'userdata');  % To reference ud.dimred
    ind = strmatch(typ,ud.dimred,'exact');
    set(H.data,'value',ind)
    
    
elseif strcmp(arg,'cmdsout')
    % output CMDS-projected data to the workspace.
    tg = findobj('tag','mdsgui');
    H = get(tg,'userdata');
    ud = get(0,'userdata');
    [n,p] = size(ud.X);
    % get the number of dimensions 
    d = round(str2num(get(H.cmdsdim,'string')));
    if d < 2 | d > p
        errordlg('Dimensions d must be in the interval 2 <= d <= p')
        return
    end
    if ~isempty(ud.cmds)
        data = ud.cmds(:,1:d);
    else
        errordlg('You have not done the scaling yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Data from Classical MDS to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)

elseif strcmp(arg,'mdsout')
    % Export projected data to the workspace.
    % First get the data and project.
    tg = findobj('tag','mdsgui');
    H = get(tg,'userdata');
    ud = get(0,'userdata');
    [n,p] = size(ud.X);
    if ~isempty(ud.mds)
        data = ud.mds;
    else
        errordlg('You have not reduced the data yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Data from Current Projection Plane to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)
    

elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','mdsgui');
    H = get(tg,'userdata');
    if ~isempty(H.plots)
        button = questdlg('Closing this GUI will close the associated plot windows.',...
            'Closing GUI Warning','OK','Cancel','Cancel');
        if strcmp(button,'Cancel')
            return
        else
            close(H.plots)
        end
    end
    delete(tg)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function domds
% Do metric/nonmetric MDS
% This uses the EDA Toolbox functions for MDS.
% The SMACOF function is used for metric MDS.
% The Kruskal function is used for non-metric - with minkowski metric of 2.

% first get the data
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
[n,p] = size(ud.X);
% Get the information from the GUI.
tg = findobj('tag','mdsgui');
H = get(tg,'userdata');
% First see if the data matrix is a 'distance' matrix.
if ~isequal(ud.X',ud.X)
    % then it is not a distance matrix.
    % So, calculate the distances.
    % Get type of distance chosen.
    distyp = get(H.mdsdist,'value');
    switch distyp
        case 1
            diststr = 'euclidean';
        case 2
            diststr = 'seuclidean';
        case 3
            diststr = 'cityblock';
        case 4
            diststr = 'mahalanobis';
        case 5
            diststr = 'minkowski';
    end
    dist = squareform(pdist(ud.X,diststr));
else
    dist = ud.X;
end
% Get the number of dimensions.
d = round(str2num(get(H.mdsdim,'string')));
if d < 2 | d > p
    errordlg('Dimensions d must be in the interval 2 <= d <= p')
    return
end
% Get the desired starting configuration type.
starttyp = get(H.starttype,'value');
ud.mds = smacof(dist,starttyp,d);
set(0,'userdata',ud);

% Note that the projections are over-written. The user must save to the
% workspace for other structures. The user can call up the GEDA GUI and
% view the current restults. (so it is good that we are saving to the
% userdata first.) The user can then run it again, view it again, etc. 
ud = get(0,'userdata');
ud.dimred = unique([ud.dimred,{'MDS'}]);
% reset the popupmenu on the clustering/GEDA GUIs if open.
updatemenu(ud.dimred)
set(0,'userdata',ud)

helpdlg({'MDS is finished.'},'MDS Status')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function docmds
% Do classical MDS

% first get the data
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
[n,p] = size(ud.X);
% Get the information from the GUI.
tg = findobj('tag','mdsgui');
H = get(tg,'userdata');
% First see if the data matrix is a 'distance' matrix.
if ~isequal(ud.X',ud.X)
    % then it is not a distance matrix.
    % So, calculate the distances.
    % Get type of distance chosen.
    distyp = get(H.cmdsdist,'value');
    switch distyp
        case 1
            diststr = 'euclidean';
        case 2
            diststr = 'seuclidean';
        case 3
            diststr = 'cityblock';
        case 4
            diststr = 'mahalanobis';
        case 5
            diststr = 'minkowski';
    end
    dist = squareform(pdist(ud.X,diststr));
else
    dist = ud.X;
end

% Do classical MDS. ud.cmds contains the n by p matrix of coordinates in
% the principal coordinate space - classical MDS.
[ud.cmds,eigvals] = cmdscale(dist);
set(0,'userdata',ud);

% Do the scree plot
hf = figure;
set(hf,'numbertitle','off','name','EDA: Classical MDS Scree Plot')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'tg = findobj(''tag'',''mdsgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)
plot(eigvals(1:10), 'bo-'); 
ylabel('Eigenvalue'); 
xlabel('Dimensionality'); 
    
% Note that the projections are over-written. The user must save to the
% workspace for other structures. The user can call up the GEDA GUI and
% view the current restults. (so it is good that we are saving to the
% userdata first.) The user can then run it again, view it again, etc. 
ud = get(0,'userdata');
ud.dimred = unique([ud.dimred,{'CMDS'}]);
% reset the popupmenu on the clustering/GEDA GUIs if open.
updatemenu(ud.dimred)
set(0,'userdata',ud)

helpdlg({'CMDS is finished.'},'CMDS Status')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveinfo(promptstrg,titlestrg,def,data)

% data is the information to be saved to the workspace
answer = inputdlg(promptstrg,titlestrg,1,def);

if ~isempty(answer)
	assignin('base',answer{1},data)
% else
% 	assignin('base','data,H.data')
end

function X = smacof(D,starttyp,d)
% Function for doing the SMACOF algorithm for metric MDS. This is used in
% the GUI system only.
% Note that D is the full interpoint distance matrix.
% starttyp is a flag indicating the type of starting configuration:
% RANDOM or CLASSICAL MDS.
% The third argument 'd' is the number of dimensions.

% This is a full interpoint distance matrix.
[n,p] = size(D);
% Turn off this warning...
warning off MATLAB:divideByZero

% Get the first term of stress.
% This is fixed - does not depend on the configuration.
stress1 = sum(sum(D.^2))/2;  
% Now find an initial configuration - randomly generate.
% First need to compute the random starting point.
switch starttyp
    case 1
        % This is the classical MDS solution.
        Y = cmdscale(D);
        Z = Y(:,1:d);
    case 2
        % Random starting point 
        Z = unifrnd(-2,2,n,d);
end
% Find the stress for this.
DZ = squareform(pdist(Z));
stress2 = sum(sum(DZ.^2))/2;
stress3 = sum(sum(D.*DZ));
oldstress = stress1 + stress2 - stress3;

% Iterate until stress converges.
tol = 10^(-6);
dstress = realmax;
numiter = 1;
dstress = oldstress;
while dstress > tol & numiter <= 1000
    numiter = numiter + 1;
    % Now get the update
    BZ = -D./DZ;
    for i = 1:n
        BZ(i,i) = 0;
        BZ(i,i) = -sum(BZ(:,i));
    end
    X = n^(-1)*BZ*Z;
    Z = X;
    % Now get the distances
    % Find the stress
    DZ = squareform(pdist(Z));
    stress2 = sum(sum(DZ.^2))/2;
    stress3 = sum(sum(D.*DZ));
    newstress = stress1 + stress2 - stress3;
    dstress = oldstress - newstress;
    oldstress = newstress;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function updatemenu(strg)
% This updates the popupmenus for any of the GUIs that can use the
% dim-reduced data.
tg =  findobj('tag','agcgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',strg);
end
tg =  findobj('tag','kmeansgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',strg);
end
tg =  findobj('tag','mbcgui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',strg);
end
tg =  findobj('tag','gedagui');
if ~isempty(tg)
    H = get(tg,'userdata');
    set(H.data,'string',strg);
end
