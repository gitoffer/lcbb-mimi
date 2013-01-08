function mbcgui(arg)
% MBCGUI  Model-Based Clustering GUI
%
% This GUI function drives the Model-Based Clustering methodology. 
% Model-based clustering includes three main components. The
% first is model-based agglomerative clustering that gives an initial
% configuration for the EM algorithm. Next is the EM or
% Expectation-Maximization algorithm. This method refines the estimate
% obtained from model-based agglomerative clustering. Finally, we have the
% Bayesian Information Criterion that provides a measure of the
% appropriateness of the final result. It helps one choose the final model.
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       mbcgui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','mbcgui');
if isempty(flg)
    % then create the gui
    mbclayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'doclus')
    % Start the clustering.
    doclus
    
elseif strcmp(arg,'doplot')
    % Construct the plots.
    doplot
    
elseif strcmp(arg,'update')
    update(gcf)
    
elseif strcmp(arg,'cidsout')
    % output CMDS-projected data to the workspace.
    ud = get(0,'userdata');
    if isempty(ud.mbcids)
        errordlg('You must cluster the data first.')
        return
    end
    [n,p] = size(ud.X);
    tg = findobj('tag','mbcgui');
    H = get(tg,'userdata');
    % Get the chosen model 
    model = get(H.model,'value');
    % Get the number of clusters to output.
    k = round(str2num(get(H.k,'string')));
    % Get maximum number of clusters
    maxclus = str2num(get(H.maxclus,'string'));
    if k < 2 | k > maxclus
        errordlg(['Number of clusters must be in the interval 2 to ' int2str(maxclus)])
        return
    end
    
    
    % Get the proper stuff based on what the user has chosen.
    mus = H.allmodels(model).clus(k).mus;
    pies = H.allmodels(model).clus(k).pies;
    vars = H.allmodels(model).clus(k).vars;
    cids = mixclass(H.X,pies,mus,vars);
    
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Cluster IDs to Workspace';
    def = {'cids'};
    saveinfo(promptstrg,titlestrg,def,cids)    

elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','mbcgui');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doclus
% Do the clustering

% first get the data
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
[n,p] = size(ud.X);
% Get the information from the GUI.
tg = findobj('tag','mbcgui');
H = get(tg,'userdata');
% Get the dataset to be used.
tmp = get(H.data,'string');
dataset = tmp{get(H.data,'value')};
switch dataset
    case 'X'
        % use the original data ud.X
        data = ud.X;
    case 'PCA'
        % use PCA field. this is the projection matrix so data =
        % ud.X*ud.pca(:,1:d). 
        % MUST ASK USER FOR THE VALUE OF D.
        prompt = {'Enter the number of dimensions:'};
        dlgTitle = 'Input for number of dimensions to use';
        def = {'2'};
        answer=inputdlg(prompt,dlgTitle,1,def);
        drawnow
        if ~isempty(answer)
            d = round(str2num(answer{1}));
            if d < 2 | d > p
                errordlg('Dimensions d must be in the interval 2 <= d <= p')
                return
            end
            data = ud.X*ud.pca(:,1:d);
        end
    case 'LLE'
        data = ud.LLE;
    case 'HLLE'
        data = ud.hLLE;
    case 'ISOMAP'
        % Check to see what is saved there. Might be the whole thing or
        % might be just what the user outputs. Depends on whether the other
        % gui is open or not.
        % if iscell - then get the right number of dimensions wanted - like
        % pca. else it is double - correct array to just use.
        if ~iscell(ud.isomap)
            data = ud.isomap;
        else
            prompt = {'Enter the number of dimensions:'};
            dlgTitle = 'Input for number of dimensions to use';
            def = '2';
            answer=inputdlg(prompt,dlgTitle,1,def);
            if ~isempty(answer)
                d = round(str2num(answer));
                if d < 2 | d > p
                    errordlg('Dimensions d must be in the interval 2 <= d <= p')
                    return
                end
                data = ud.isomap{d}';                
            end
            
        end

end
H.X = data;  % need this later on for outputting of CIDS.

% Get the maximum number of clusters.
maxclus = round(str2num(get(H.maxclus,'string')));
if maxclus < 1 | maxclus > 20
    errordlg('Number of clusters must be in the interval 1 to 20')
    return
end


% Do the clustering. 

[H.bics,H.bestmodel,H.allmodels,Z,ud.mbcids] = mbclust(real(data),maxclus);

[maxbic,maxi] = max(H.bics(:));
[mi,mj] = ind2sub(size(H.bics),maxi);

set(H.bmodtxt,'string',['Best model: ' int2str(mi)])
set(H.nctxt,'string',['Number of clusters: ' int2str(mj)])

uiwait(msgbox('Data have been clustered.','Cluster Status','modal'))

set(0,'userdata',ud);
set(tg,'userdata',H);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doplot
% Do the various plots. 

ud = get(0,'userdata');

% Set up the proper stuff for the plot windows.
tg = findobj('tag','mbcgui');
H = get(tg,'userdata');

if isempty(ud.mbcids)
    errordlg('You must cluster the data first.')
    return
end

% Get the type of plot.
plotyp = get(H.plotyp,'value');

hf = figure;
set(hf,'numbertitle','off','visible','off')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'mbcgui(''update'');tg = findobj(''tag'',''mbcgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];

% Set up stuff for brushing. 
set(hf,'RendererMode','manual',...
        'backingstore','off',...
        'renderer','painters',...
        'DoubleBuffer','on');
    
set(tg,'userdata',H)

switch plotyp
    case 2
        % Reclus
        set(hf,'name','EDA: ReClus MBC','visible','on')
        figure(hf)
        [Hline, Haxs] = reclusg(ud.mbcids);

        % Set up in the information for the plot menu.
        % See if the brushgui is open. Reset the popupmenu string
        hbgui = findobj('tag','brushgui');
        newstrg = 'ReClus MBC';
        if ~isempty(ud.brushptr) & ~isempty(hbgui)
            % tack on the plot to the open brushgui menu
            Hud = get(hbgui,'userdata');
            strg = get(Hud.popplot,'string');
            if ~iscell(strg)
                strg = [{strg};{newstrg}];
            else
                strg = [strg;{newstrg}];
            end
            set(Hud.popplot,'string',strg)
        elseif ~isempty(hbgui)
            % it must be 'none'
            Hud = get(hbgui,'userdata');
            set(Hud.popplot,'string',newstrg)
        end
        % This plot can be brushed (and linked).
        % Linking will be taken care of by merging this with the others
        % that are only linkable.
        ud.brushptr = [ud.brushptr, hf];
        ud.brush = [ud.brush, Hline];
        % Save handles to highlighted axes in here.
        ud.highlight = [ud.highlight,Haxs];
        
        set(0,'userdata',ud)
        
    case 1
        % Plot BICS
        set(hf,'name','EDA: BIC Plot','visible','on')
        figure(hf)
        if ~isempty(H.bics)
            plotbic(H.bics)
        else
            close(hf)
            errordlg('You must cluster the data to plot the BICs.')
            return
        end
        
    case 3
        % GEDA GUI
        close(hf)
        gedagui
       
end
       


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveinfo(promptstrg,titlestrg,def,data)

% data is the information to be saved to the workspace
answer = inputdlg(promptstrg,titlestrg,1,def);

if ~isempty(answer)
	assignin('base',answer{1},data)
% else
% 	assignin('base','data,H.data')
end

%%%%%%%%%%%%%%%%%%%%%%
function update(fig)
% fig should be the handle to the plot that is closing.
% Use this function to update the brush/link information
ud = get(0,'userdata');

% the following are andrews/parallel, where we have n lines per plot.
inds = find(ud.linkptrap == fig);
if ~isempty(inds)
    ud.linkptrap(inds) = [];
    ud.linkap(:,inds) = [];
end
% The following array keeps the highlighted axes for all figures. 
% Reset to empty. 
Haxes = findobj(fig,'type','axes');
[c,inda,indb] = intersect(ud.highlight,Haxes);
ud.highlight(inda) = [];
% see if this is the current brushing plot.
Hbgui = findobj('tag','brushgui');
if ~isempty(Hbgui)
    H = get(Hbgui,'userdata');
    if H.brushplot == fig
        % then this is the current plot being brushed.
        H.brushplot = [];
        H.Hbrush = [];
        H.BrushPrevX = [];
        H.BrushPrevY = [];
        % RESET ALL PLOTs to the normal one.
        brushgui('reset')
        % reset the userdata in brushgui
        set(Hbgui,'userdata',H)
    end
end

inds = find(ud.brushptr == fig);
% Now update the brushgui popupmenu
if ~isempty(Hbgui)
    if length(ud.brushptr) == 1
        strg = {'None'};
    else
        strg = get(H.popplot,'string');
        strg(inds) = [];        % delete from the menu string.
    end
    if isempty(ud.brushptr)
        strg = {'None'};
    end
    set(H.popplot,'string',strg)
    % reset the userdata in brushgui
    set(Hbgui,'userdata',H)
end

% update the brushptr array.
if ~isempty(inds)
    ud.brushptr(inds) = [];
    ud.brush(inds) = [];    % these are all single handles to line objects
end

set(0,'userdata',ud)
