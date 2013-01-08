function dimredgui(arg, typ)
% DIMREDGUI  Dimensionality Reduction GUI
%
% This GUI function provides access to the Dimensionality Reduction
% methods. These include Principal Component Analysis, Isometric Feature
% Mapping, and Locally Linear Embeddings. 
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       dimredgui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','dimredgui');
if isempty(flg)
    % then create the gui
    dimredlayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'dopca')
    % Start the PCA process.
    dopca

    
elseif strcmp(arg,'doisomap')
    % Do the ISOMAP procedure
    doisomap

    
elseif strcmp(arg,'dolle')
    % Do the LLE procedures
    dolle
    
elseif strcmp(arg,'geda')
    % Bring up the graphical EDA GUI
    % First get the number of desired dimensions.
    % Get the information from the GUI.
%     tg = findobj('tag','dimredgui');
%     H = get(tg,'userdata');
%     ud = get(0,'userdata');
%     [n,p] = size(ud.X);
%     % get the number of dimensions 
%     MIGHT NEED ONE OF THESE FOR EACH TYPE OF GEDA BUTTON!!!
    gedagui
    % Added the following, Sep 14
    tg = findobj('Tag','gedagui');
    H = get(tg,'userdata');  % To reference H.data
    ud = get(0,'userdata');  % To reference ud.dimred
    ind = strmatch(typ,ud.dimred,'exact');
    set(H.data,'value',ind)
    
elseif strcmp(arg,'pcaout')
    % output PCA-projected data to the workspace.
    tg = findobj('tag','dimredgui');
    H = get(tg,'userdata');
    ud = get(0,'userdata');
    [n,p] = size(ud.X);
    % get the number of dimensions 
    d = round(str2num(get(H.pcadim,'string')));
    if d < 2 | d > p
        errordlg('Dimensions d must be in the interval 2 <= d <= p')
        return
    end
    if ~isempty(ud.pca)
        data = ud.X*ud.pca(:,1:d);
    else
        errordlg('You have not found the projection matrix yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Data from PCA to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)

elseif strcmp(arg,'isomapout')
    % Export projected data to the workspace.
    % First get the data and project.
    tg = findobj('tag','dimredgui');
    H = get(tg,'userdata');
    ud = get(0,'userdata');
    [n,p] = size(ud.X);
    % get the number of dimensions 
    d = round(str2num(get(H.isodim,'string')));
    % Note that maximum number of dimensions with ISOMAP (default) is 10.
    % So the user can only get a maximum of p (if p <= 10) or 10.
    if d < 2 | d > 10
        errordlg('Dimensions d must be in the interval 2 <= d <= 10')
        return
    end
    if ~isempty(ud.isomap)
        data = ud.isomap{d}';
%         [ntmp,ptmp] = size(data);
%         if ntmp < n
%             % Then the graph was not fully connected. must make the
%             % neighborhood bigger.
%             errordlg('The nearest neighbor graph was not fully connected. Increase the size of the neighborhood.')
%             return
%         end
    else
        errordlg('You have not reduced the data yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Data from ISOMAP to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)
    
elseif strcmp(arg,'lleout')
    % Export projected data to the workspace.
    % First get the data and project.
    tg = findobj('tag','dimredgui');
    H = get(tg,'userdata');
    ud = get(0,'userdata');
    [n,p] = size(ud.X);
    % get the number of dimensions 
    d = round(str2num(get(H.lledim,'string')))
    if d < 2 | d > p
        errordlg('Dimensions d must be in the interval 2 <= d <= p')
        return
    end
    if ~isempty(ud.LLE) | ~isempty(ud.hLLE)
        % Get type of LLE chosen.
        lletyp = get(H.lletype,'value');
        if lletyp == 1
            % Chose to do the regular LLE
            data = ud.LLE;
        else
            % Chose to do the HLLE - Hessian LLE
            data = real(ud.hLLE);
        end
    else
        errordlg('You have not reduced the data yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Data from LLE to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)

elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','dimredgui');
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
    ud = get(0,'userdata');
    [n,p] = size(ud.X);
     % get the number of dimensions 
     d = round(str2num(get(H.isodim,'string')));
     if ~isempty(ud.isomap) & iscell(ud.isomap)
         % just save the data for the desired dimensionality.
         ud.isomap = ud.isomap{d}';
%          [ntmp,ptmp] = size(ud.isomap);
%          if ntmp < n
%              % Then the graph was not fully connected. must make the
%              % neighborhood bigger.
%              errordlg('Cannot extract ISOMAP embedding - the nearest neighbor graph was not fully connected. Increase the size of the neighborhood and/or change the distance used and rerun ISOMAP.')
%              return
%          end
%          
     end
     set(0,'userdata',ud);
     delete(tg)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doisomap

% first get the data
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
[n,p] = size(ud.X);
% Get the information from the GUI.
tg = findobj('tag','dimredgui');
H = get(tg,'userdata');
% Get type of distance chosen.
distyp = get(H.isodist,'value');
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
% Now get the number of neighbors.
K = round(str2num(get(H.isok,'string')));
if K < 1
    errordlg('Number of nearest neighbors must be greater than or equal to 1')
    return
end
% Get the flag for a scree plot
scree = get(H.isoscree,'value');
options.display = 0;
options.overlay = 0;
if p < 10
    % Then only find embeddings up to p.
    options.dims = 1:p;
else
    options.dims = 1:10;
end
% Note that the following will return embeddings up to 10-d.
[Y, R] = isomap(dist, 'k', K, options); 
ud.isomap = Y.coords;
set(0,'userdata',ud);
% Output: 
%    Y = Y.coords is a cell array, with coordinates for d-dimensional embeddings
%         in Y.coords{d}.  Y.index contains the indices of the points embedded.
%    R = residual variances for embeddings in Y
%    E = edge matrix for neighborhood graph
% Plot the scree plot, if desired.
if scree
    hf = figure;
    set(hf,'numbertitle','off','name','EDA: ISOMAP Scree Plot')
    % Upon figure close, this should delete from the array.
    set(hf,'CloseRequestFcn',...
        'tg = findobj(''tag'',''dimredgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
    H.plots = [H.plots, hf];
    set(tg,'userdata',H)
    hold on
    plot(options.dims, R, 'bo'); 
    plot(options.dims, R, 'b-'); 
    hold off
    ylabel('Residual variance'); 
    xlabel('Isomap dimensionality'); 
end

ud = get(0,'userdata');
ud.dimred = unique([ud.dimred,{'ISOMAP'}]);
updatemenu(ud.dimred)
set(0,'userdata',ud)

% Provide information to the user at this point that the graph was
% unconnected. So, the number of data points returned by isomap is less
% than n. They need to increase the size of the neighborhood or change the 
% distance used.

[ntmp,ptmp] = size(ud.isomap{1}');

if ntmp < n
    % Then the graph was not fully connected. must make the
    % neighborhood bigger.
    msgbox('The nearest neighbor graph was not fully connected, so the output to other GUIs will be less than n. Either increase the size of the neighborhood or try a different distance if you want all observations in the reduced space.','ISOMAP Information','warn')
   
end

helpdlg({'ISOMAP is finished.'},'ISOMAP Status')

% For now, keep all embeddings in the root userdata under ud.isomap. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dopca
% first get the data
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
[n,p] = size(ud.X);
% Get the information from the GUI.
tg = findobj('tag','dimredgui');
H = get(tg,'userdata');
% Get the type of PCA - covariance or correlation
typ = get(H.pcatype,'value');
if typ == 1
    % Then they want PCA with covariance matrix.
    mat = cov(ud.X);
else
    % Then they wan the PCA with correlation matrix.
    mat = corrcoef(ud.X);
end
% Get types of outputs
scree = get(H.pcascree,'value');

% Do the PCA process
[evec,D] = eig(mat);
eval = diag(D);
% sort so that first ones are highest variance.
[evals,inds] = sort(eval);
evals = flipud(evals);
inds = flipud(inds);
% reorder the eigenvectors, too.
evecs = evec(:,inds);
ud.pca = evecs;
set(0,'userdata',ud)

% Plot the scree plot, if desired.
if scree
    hf = figure;
    set(hf,'numbertitle','off','name','EDA: PCA Scree Plot')
    % Upon figure close, this should delete from the array.
    set(hf,'CloseRequestFcn',...
        'tg = findobj(''tag'',''dimredgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
    H.plots = [H.plots, hf];
    set(tg,'userdata',H)
    plot(evals, 'bo-'); 
    ylabel('Eigenvalue'); 
    xlabel('Component Number'); 
end

% Get the information regarding desired methods of choosing dimensions. 
if get(H.pcapv,'value')
    % This is the % variance explained.
    pervar = 100*cumsum(evals)/sum(evals);
    % Find the top 90%.
    Kpv = length(find(pervar > 90));
    set(H.pcapv,'String',['% Variance: ' int2str(Kpv)])
end
if get(H.pcacv,'value')
    % This is really going to be the size of the eigenvalues.
    avgeig = mean(evals);
    % Find the length of ind:
    Ksz = length(find(evals > avgeig));
    set(H.pcacv,'string',['Size of Var: ' int2str(Ksz)])
end
if get(H.pcabs,'value')
    % This is the broken stick.
    % First get the expected lengths/sizes of the eigenvalues.
    g = zeros(1,p);
    for j = 1:p
        for i = j:p 
            g(j) = g(j) + 1/i;
        end
    end
    g = g/p;
    % what is the proportion of variance explained. 
    propvar = evals/sum(evals);
    % % now find those that explain more than the expected amount.
    Kbs = length(find(propvar' > g));
    set(H.pcabs,'string',['Broken Stick: ' int2str(Kbs)])
end

ud = get(0,'userdata');
ud.dimred = unique([ud.dimred,{'PCA'}]);
% reset the popupmenu on the clustering/GEDA GUIs if open.
updatemenu(ud.dimred)
set(0,'userdata',ud)

helpdlg({'PCA is finished.'},'PCA Status')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dolle

% first get the data
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
[n,p] = size(ud.X);
% Get the information from the GUI.
tg = findobj('tag','dimredgui');
H = get(tg,'userdata');
% Now get the number of neighbors.
K = round(str2num(get(H.llek,'string')));
if K < 1
    errordlg('Number of nearest neighbors must be greater than or equal to 1')
    return
end
% get the number of dimensions 
d = round(str2num(get(H.lledim,'string')));
if d < 2 | d > p
    errordlg('Dimensions d must be in the interval 2 <= d <= p')
    return
end
% Get type of LLE chosen.
lletyp = get(H.lletype,'value');
if lletyp == 1
    % Chose to do the regular LLE
    % REMEMBER that the input is of size p x n.
    Y = lle(ud.X',K,d);
    ud.LLE = Y';
    ud.dimred = unique([ud.dimred,{'LLE'}]);
    updatemenu(ud.dimred)
    helpdlg({'LLE is finished.'},'LLE Status')
else
    % Chose to do the HLLE - Hessian LLE
    [Y, mse] = hlle(ud.X',K,d);
    ud.hLLE = Y';
    ud.dimred = unique([ud.dimred,{'HLLE'}]);
    updatemenu(ud.dimred)
    helpdlg({'HLLE is finished.'},'HLLE Status')
end
set(0,'userdata',ud)



% For now, keep all embeddings in the root userdata under ud.LLE and ud.hLLE. Once
% the GUI closes, clear this from the userdata - in the interest of space. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveinfo(promptstrg,titlestrg,def,data)

% data is the information to be saved to the workspace
answer = inputdlg(promptstrg,titlestrg,1,def);

if ~isempty(answer)
	assignin('base',answer{1},data)
% else
% 	assignin('base','data,H.data')
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
