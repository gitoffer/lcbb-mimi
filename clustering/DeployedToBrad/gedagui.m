function gedagui(arg)
% GEDAGUI   Graphical Exploratory Data Analysis GUI
%
% This provides access to various graphical EDA methods. These include 2-D
% scatterplots, 3-D scatterplots, scatterplot matrices with brushing,
% Andrews' curves plots, and parallel coordinate plots. 
%
% The GUI also provides access to the Brushing and Labeling GUI. 
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       gedagui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','gedagui');
if isempty(flg)
    % then create the gui
    gedalayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'twodscatter')
    twodscatter
    
elseif strcmp(arg,'threedscatter')
    threedscatter
    
elseif strcmp(arg,'scattermat')
    scattermat
    
elseif strcmp(arg,'brushlink')
    brushlink
    
elseif strcmp(arg,'parallel')
   doparallel
        
elseif strcmp(arg,'andrews')
    doandrews
    
elseif strcmp(arg,'update')
    update(gcf)

elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','gedagui');
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
      % If the brushgui is open, then it needs to be closed. This is only
    % accessible through this GUI or the main edaGUI.
    flg = findobj('tag','brushgui');
    if ~isempty(flg)
        close(flg)
    end
    
    % Now delete the gedagui
    delete(tg)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function twodscatter

tg = findobj('tag','gedagui');
H = get(tg,'userdata');
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end

% Get the dataset to be used.
tmp = get(H.data,'string');
dataset = tmp{get(H.data,'value')};
switch dataset
    case 'X'
        % use the original data data
        data = ud.X;
        xstr = 'X';
    case 'PCA'
        % use PCA field. this is the projection matrix so data =
        % data*ud.pca(:,1:d). 
        % CHANGED THE FOLLOWING ON 11-6-05. JUST PROVIDE ALL 4 DIMENSIONS
        % FOR PCA. THE USER CAN THEN PLOT WHICH ONES THEY WANT.
        data = ud.X*ud.pca;
        xstr = 'PCA';

    case 'LLE'
        data = ud.LLE;
        xstr = 'LLE';
    case 'HLLE'
        data = ud.hLLE;
        xstr = 'HLLE';
    case 'ISOMAP'
        % Check to see what is saved there. Might be the whole thing or
        % might be just what the user outputs. Depends on whether the other
        % gui is open or not.
        % if iscell - then get the right number of dimensions wanted - like
        % pca. else it is double - correct array to just use.
        % CHANGED THIS ON 11-6-05. JUST SAVE THE MAXIMUM NUMBER OF
        % DIMENSIOns.
        [n,p] = size(ud.X);
        if ~iscell(ud.isomap)
            data = ud.isomap;
        else
            data = ud.isomap{end}';
        end
        xstr = 'ISOMAP';
        
    case 'MDS'
        % Added 11-12-05 - Process the MDS data.
        data = ud.mds;
        xstr = 'MDS';
        
    case 'CMDS'
        % Added 11-12-05 - Process the CMDS data.
        data = ud.cmds;
        xstr = 'CMDS';
        
    case 'PPEDA'
        % Added 11-12-05 - Process the PPEDA data.
        Z = sphere(ud.X);
        data = Z*ud.ppeda;
        xstr = 'PPEDA';
        
end
[n,p] = size(data);

% Get the information for plotting: Dimensions to use.
tmp = get(H.dim2D,'string');
eval(['dim2d = [' tmp '];']);
dim2d = round(dim2d);
if length(dim2d) ~= 2
    errordlg('Must enter two dimensions to plot.')
    return
end

if any(dim2d < 1) | any(dim2d > p)
    errordlg(['Dimensions must be between 1 and ' int2str(p)])
    return
end
if dim2d(1) == dim2d(2)
    errordlg('Dimensions must be different.')
    return
end
% Get the color by groups flag.
colflag = get(H.popmode,'value');
% OK to plot
hf = figure;
set(hf,'tag','2D','numbertitle','off','name','EDA: 2-D Scatterplot','visible','off')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'gedagui(''update'');tg = findobj(''tag'',''gedagui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
% Set up stuff for brushing. 
set(hf,'RendererMode','manual',...
        'backingstore','off',...
        'renderer','painters',...
        'DoubleBuffer','on');
      
H.plots = [H.plots, hf];
set(tg,'userdata',H)

% Will need to store the handle for this window in the proper field for
% brush/link.
% The following is used for brush/link purposes. 
figure(hf)
fud = [];
switch colflag
    case 1
        % just do a plain plot
        set(hf,'visible','on')
        set(hf,'backingstore','off','renderer','painters','DoubleBuffer','on')
        Hline = plot(data(:,dim2d(1)),data(:,dim2d(2)),'ko');
        % This is for brushing/linking.
        % Default color and 'undo' color is black!
        % Non-highlighted data will have a tag of 'black'
        set(Hline,'markersize',3,'marker','o','linestyle','none',...
            'markerfacecolor','w',...
            'tag','black')
        % NOTE: one handle per line. Access color of individual points by
        % the 'xdata' and 'ydata' indices.
        % Put proper labels on there. Check to see if any are loaded.

        % This next section added nov 5.
        if strcmp(dataset,'X')
            % Then we are plotting the regular data set. Just use the
            % regular labels.
            xlabel(ud.varlab{dim2d(1)},'handlevisibility','on')
            ylabel(ud.varlab{dim2d(2)},'handlevisibility','on')
            newstrg = [ud.varlab{dim2d(1)} ' vs ' ud.varlab{dim2d(2)}];
        else
            % Then we are plotting something else - PCA, etc.
            xlabel([xstr ' ' int2str(dim2d(1))],'handlevisibility','on');
            ylabel([xstr ' ' int2str(dim2d(2))],'handlevisibility','on');
            % set up the string for the popupmenu
            newstrg = [xstr int2str(dim2d(1)) xstr int2str(dim2d(2))];
        end


        % Set up in the information for the plot menu.
        % See if the brushgui is open. Reset the popupmenu string
        hbgui = findobj('tag','brushgui');
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
        ud.highlight = [ud.highlight,gca];

        set(0,'userdata',ud)
        axis manual

    case 2
        % Color by groups - must be loaded by the user. Not from
        % clustering.
        if isempty(ud.classlab)
            errordlg('You must load some group labels.')
            close(hf)
            return
        end
        set(hf,'visible','on')
        gscatter(data(:,dim2d(1)),data(:,dim2d(2)),ud.classlab);
        % This next section added nov 5.
        if strcmp(dataset,'X')
            % Then we are plotting the regular data set. Just use the
            % regular labels.
            xlabel(ud.varlab{dim2d(1)},'handlevisibility','on')
            ylabel(ud.varlab{dim2d(2)},'handlevisibility','on')
            newstrg = [ud.varlab{dim2d(1)} ' vs ' ud.varlab{dim2d(2)}];
        else
            % Then we are plotting something else - PCA, etc.
            xlabel([xstr ' ' int2str(dim2d(1))],'handlevisibility','on');
            ylabel([xstr ' ' int2str(dim2d(2))],'handlevisibility','on');
            % set up the string for the popupmenu
            newstrg = [xstr int2str(dim2d(1)) xstr int2str(dim2d(2))];
        end

    case 3
        % Color by clusters.
        if isempty(ud.kmeansids) & isempty(ud.agcids) & isempty(ud.mbcids)
            % haven't clustered anything yet.
            errordlg('You must create some clusters first.')
            close(hf)
            return
        end
        menustrg = [];
        cidstr = [];
        if ~isempty(ud.kmeansids)
            menustrg = [menustrg, {'k-Means Clusters'}];
            cidstr = [cidstr, {'ud.kmeansids'}];
        end
        if ~isempty(ud.agcids)
            menustrg = [menustrg, {'Agglomerative Clustering'}];
            cidstr = [cidstr, {'ud.agcids'}];
        end
        if ~isempty(ud.mbcids)
            menustrg = [menustrg, {'Model-Based Clustering'}];
            cidstr = [cidstr, {'ud.mbcids'}];
        end
        if length(cidstr) == 1
            % no need for a listbox. Just plot.
            set(hf,'visible','on')
            eval(['gscatter(data(:,dim2d(1)),data(:,dim2d(2)), ' cidstr{1} ' );'])
            % Put proper labels on there. Check to see if any are loaded.
            % This next section added nov 5.
            if strcmp(dataset,'X')
                % Then we are plotting the regular data set. Just use the
                % regular labels.
                xlabel(ud.varlab{dim2d(1)},'handlevisibility','on')
                ylabel(ud.varlab{dim2d(2)},'handlevisibility','on')
                newstrg = [ud.varlab{dim2d(1)} ' vs ' ud.varlab{dim2d(2)}];
            else
                % Then we are plotting something else - PCA, etc.
                xlabel([xstr ' ' int2str(dim2d(1))],'handlevisibility','on');
                ylabel([xstr ' ' int2str(dim2d(2))],'handlevisibility','on');
                % set up the string for the popupmenu
                newstrg = [xstr int2str(dim2d(1)) xstr int2str(dim2d(2))];
            end

        else
            [sel,ok] = listdlg('PromptString','Select a type of clustering:',...
                'SelectionMode','single',...
                'ListString',menustrg);
            if ok == 1
                % person selected something.
                set(hf,'visible','on')
                eval(['gscatter(data(:,dim2d(1)),data(:,dim2d(2)), ' cidstr{sel} ' );'])
                % Put proper labels on there. Check to see if any are loaded.
                % This next section added nov 5.
                if strcmp(dataset,'X')
                    % Then we are plotting the regular data set. Just use the
                    % regular labels.
                    xlabel(ud.varlab{dim2d(1)},'handlevisibility','on')
                    ylabel(ud.varlab{dim2d(2)},'handlevisibility','on')
                    newstrg = [ud.varlab{dim2d(1)} ' vs ' ud.varlab{dim2d(2)}];
                else
                    % Then we are plotting something else - PCA, etc.
                    xlabel([xstr ' ' int2str(dim2d(1))],'handlevisibility','on');
                    ylabel([xstr ' ' int2str(dim2d(2))],'handlevisibility','on');
                    % set up the string for the popupmenu
                    newstrg = [xstr int2str(dim2d(1)) xstr int2str(dim2d(2))];
                end

            end

        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function threedscatter

tg = findobj('tag','gedagui');
H = get(tg,'userdata');
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
% Get the dataset to be used.
tmp = get(H.data,'string');
dataset = tmp{get(H.data,'value')};
switch dataset
    case 'X'
        % use the original data data
        data = ud.X;
        xstr = 'X';
    case 'PCA'
        % use PCA field. this is the projection matrix so data =
        % ud.X*ud.pca(:,1:d). 
        data = ud.X*ud.pca;
        xstr = 'PCA';

    case 'LLE'
        data = ud.LLE;
        xstr = 'LLE';
    case 'HLLE'
        data = ud.hLLE;
        xstr = 'HLLE';
    case 'ISOMAP'
        % Check to see what is saved there. Might be the whole thing or
        % might be just what the user outputs. Depends on whether the other
        % gui is open or not.
        % if iscell - then get the right number of dimensions wanted - like
        % pca. else it is double - correct array to just use.
        [n,p] = size(ud.X);
        if ~iscell(ud.isomap)
            data = ud.isomap;
        else
            data = ud.isomap{end}';
        end
        xstr = 'ISOMAP';
        
                
    case 'MDS'
        % Added 11-12-05 - Process the MDS data.
        data = ud.mds;
        xstr = 'MDS';
        
    case 'CMDS'
        % Added 11-12-05 - Process the CMDS data.
        data = ud.cmds;
        xstr = 'CMDS';
        
    case 'PPEDA'
        % Added 11-12-05 - Process the PPEDA data.
        Z = sphere(ud.X);
        data = Z*ud.ppeda;
        xstr = 'PPEDA';
       
end
[n,p] = size(data);
% Get the information for plotting: Dimensions to use.
tmp = get(H.dim3D,'string');
eval(['dim3d = [' tmp '];']);
dim3d = round(dim3d);
if length(dim3d) ~= 3
    errordlg('Must enter three dimensions to plot.')
    return
end
if any(dim3d < 1) | any(dim3d > p)
    errordlg(['Dimensions must be between 1 and ' int2str(p)])
    return
end
if length(unique(dim3d)) < 3
    errordlg('Dimensions must be different.')
    return
end
% Get the color by groups flag.
colflag = get(H.popmode,'value');
% OK to plot
hf = figure;
set(hf,'tag','3D','numbertitle','off','name','EDA: 3-D Scatterplot')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'gedagui(''update'');tg = findobj(''tag'',''gedagui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')

% Set up stuff for brushing/linking. 
set(hf,'RendererMode','manual',...
        'backingstore','off',...
        'renderer','painters',...
        'DoubleBuffer','on');
      
H.plots = [H.plots, hf];
set(tg,'userdata',H)

% Will need to store the handle for this window in the proper field for
% brush/link.
% The following is used for brush/link purposes. 
figure(hf)
fud = [];
switch colflag
    case 1
        % just do a plain plot - do link parallel/Andrews curves - one line
        % per observation. makes it easier to brush/link
        set(hf,'visible','on')
        set(hf,'backingstore','off','renderer','painters','DoubleBuffer','on')
        Hline = zeros(length(data(:,1)),1);
        Hline(1) = plot3(data(1,dim3d(1)),data(1,dim3d(2)),data(1,dim3d(3)),'ko');
        hold on
        for ii = 2:length(data(:,1))
            Hline(ii) = plot3(data(ii,dim3d(1)),data(ii,dim3d(2)),data(ii,dim3d(3)),'ko');
            set(Hline(ii),'markersize',3,'marker','o','linestyle','none',...
            'markerfacecolor','w')
        end
        hold off
        ud.linkptrap = [ud.linkptrap, hf];
        ud.linkap = [ud.linkap, Hline(:)];

        set(0,'userdata',ud)
        % Put proper labels on there. Check to see if any are loaded.
        % This next section added nov 5.
        if strcmp(dataset,'X')
            % Then we are plotting the regular data set. Just use the
            % regular labels.
            xlabel(ud.varlab{dim3d(1)},'handlevisibility','on')
            ylabel(ud.varlab{dim3d(2)},'handlevisibility','on')
            zlabel(ud.varlab{dim3d(3)},'handlevisibility','on')
        else
            % Then we are plotting something else - PCA, etc.
            xlabel([xstr ' ' int2str(dim3d(1))],'handlevisibility','on');
            ylabel([xstr ' ' int2str(dim3d(2))],'handlevisibility','on');
            zlabel([xstr ' ' int2str(dim3d(3))],'handlevisibility','on');
            % set up the string for the popupmenu
        end
        box on
        grid on
        
%         axis manual

    case 2
        % Color by groups - must be loaded by the user. Not from
        % clustering.
        if isempty(ud.classlab)
            errordlg('You must load some group labels.')
            close(hf)
            return
        end
        gscatter3(data(:,dim3d(1)),data(:,dim3d(2)),data(:,dim3d(3)),ud.classlab);
        % This next section added nov 5.
        if strcmp(dataset,'X')
            % Then we are plotting the regular data set. Just use the
            % regular labels.
            xlabel(ud.varlab{dim3d(1)},'handlevisibility','on')
            ylabel(ud.varlab{dim3d(2)},'handlevisibility','on')
            zlabel(ud.varlab{dim3d(3)},'handlevisibility','on')
        else
            % Then we are plotting something else - PCA, etc.
            xlabel([xstr ' ' int2str(dim3d(1))],'handlevisibility','on');
            ylabel([xstr ' ' int2str(dim3d(2))],'handlevisibility','on');
            zlabel([xstr ' ' int2str(dim3d(3))],'handlevisibility','on');
            % set up the string for the popupmenu
        end
    case 3
        % Color by clusters. 
        if isempty(ud.kmeansids) & isempty(ud.agcids) & isempty(ud.mbcids)
            % haven't clustered anything yet.
            errordlg('You must create some clusters first.')
            close(hf)
            return
        end
        menustrg = [];
        cidstr = [];
        if ~isempty(ud.kmeansids)
            menustrg = [menustrg, {'k-Means Clusters'}];
            cidstr = [cidstr, {'ud.kmeansids'}];
        end
        if ~isempty(ud.agcids)
            menustrg = [menustrg, {'Agglomerative Clustering'}];
            cidstr = [cidstr, {'ud.agcids'}];
        end
        if ~isempty(ud.mbcids)
            menustrg = [menustrg, {'Model-Based Clustering'}];
            cidstr = [cidstr, {'ud.mbcids'}];
        end
        if length(cidstr) == 1
            % no need for a listbox. Just plot.
            eval(['gscatter3(data(:,dim3d(1)),data(:,dim3d(2)), data(:,dim3d(3)), ' cidstr{1} ' );'])
            % This next section added nov 5.
            if strcmp(dataset,'X')
                % Then we are plotting the regular data set. Just use the
                % regular labels.
                xlabel(ud.varlab{dim3d(1)},'handlevisibility','on')
                ylabel(ud.varlab{dim3d(2)},'handlevisibility','on')
                zlabel(ud.varlab{dim3d(3)},'handlevisibility','on')
            else
                % Then we are plotting something else - PCA, etc.
                xlabel([xstr ' ' int2str(dim3d(1))],'handlevisibility','on');
                ylabel([xstr ' ' int2str(dim3d(2))],'handlevisibility','on');
                zlabel([xstr ' ' int2str(dim3d(3))],'handlevisibility','on');
                % set up the string for the popupmenu
            end
        else
            [sel,ok] = listdlg('PromptString','Select a type of clustering:',...
                'SelectionMode','single',...
                'ListString',menustrg);
            if ok == 1
                % person selected something.
                eval(['gscatter3(data(:,dim3d(1)),data(:,dim3d(2)), data(:,dim3d(3)), ' cidstr{sel} ' );'])
                % This next section added nov 5.
                if strcmp(dataset,'X')
                    % Then we are plotting the regular data set. Just use the
                    % regular labels.
                    xlabel(ud.varlab{dim3d(1)},'handlevisibility','on')
                    ylabel(ud.varlab{dim3d(2)},'handlevisibility','on')
                    zlabel(ud.varlab{dim3d(3)},'handlevisibility','on')
                else
                    % Then we are plotting something else - PCA, etc.
                    xlabel([xstr ' ' int2str(dim3d(1))],'handlevisibility','on');
                    ylabel([xstr ' ' int2str(dim3d(2))],'handlevisibility','on');
                    zlabel([xstr ' ' int2str(dim3d(3))],'handlevisibility','on');
                    % set up the string for the popupmenu
                end
            end

        end
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scattermat
% This cannot be brushed or linked. 

tg = findobj('tag','gedagui');
H = get(tg,'userdata');
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
% Get the dataset to be used.
tmp = get(H.data,'string');
dataset = tmp{get(H.data,'value')};
switch dataset
    case 'X'
        % use the original data ud.X
        data = ud.X;
        xstr = 'X';
    case 'PCA'
        % use PCA field. this is the projection matrix so data =
        % ud.X*ud.pca(:,1:d). 
        data = ud.X*ud.pca;
        xstr = 'PCA';

    case 'LLE'
        data = ud.LLE;
        xstr = 'LLE';
    case 'HLLE'
        data = ud.hLLE;
        xstr = 'HLLE';
    case 'ISOMAP'
        % Check to see what is saved there. Might be the whole thing or
        % might be just what the user outputs. Depends on whether the other
        % gui is open or not.
        % if iscell - then get the right number of dimensions wanted - like
        % pca. else it is double - correct array to just use.
        [n,p] = size(ud.X);
        if ~iscell(ud.isomap)
            data = ud.isomap;
        else
            data = ud.isomap{end}';
        end
        xstr = 'ISOMAP';
        
                
    case 'MDS'
        % Added 11-12-05 - Process the MDS data.
        data = ud.mds;
        xstr = 'MDS';
        
    case 'CMDS'
        % Added 11-12-05 - Process the CMDS data.
        data = ud.cmds;
        xstr = 'CMDS';
        
    case 'PPEDA'
        % Added 11-12-05 - Process the PPEDA data.
        Z = sphere(ud.X);
        data = Z*ud.ppeda;
        xstr = 'PPEDA';
       

end
[n,p] = size(data);
% Get the information for plotting: Dimensions to use.
tmp = get(H.dimscatter,'string');
if strcmp(lower(tmp),'all')
    % user wants all dimensions to display.
    dims = 1:p;
else
    eval(['dims = [' tmp '];']);
    dims = round(dims);
end
if any(dims < 1) | any(dims > p)
    errordlg(['Dimensions must be between 1 and ' int2str(p)])
    return
end
if length(unique(dims)) < length(dims)
    errordlg('Dimensions must be different.')
    return
end
% Get the color by groups flag.
colflag = get(H.popmode,'value');
% OK to plot
hf = figure;
set(hf,'tag','scatter','numbertitle','off','name','EDA: Scatterplot Matrix')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'gedagui(''update'');tg = findobj(''tag'',''gedagui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
set(hf,'RendererMode','manual',...
    'backingstore','off',...
    'renderer','painters',...
    'DoubleBuffer','on');
H.plots = [H.plots, hf];
set(tg,'userdata',H)

% Will need to store the handle for this window in the proper field for
% brush/link.
% The following is used for brush/link purposes. 
figure(hf)
fud = [];
switch colflag
    case 1
        % just do a plain plot
        [H,ax,BigAx,patches,pax] = plotmatrix(data(:,dims));
        % Note that in this case the Hline handles are a 3-D array. (i,j)
        % is for the i,j plot.
        % This plot can be linked.
        % Linking will be taken care of by merging this with the others
        % that are only linkable.
        % need to do some converting. Get rid of diagonal handles.
        %         ind = sub2ind(size(Hline),1:p,1:p);
        %         Hline = Hline(:);
        %         Hline(ind) = [];
        %         ud.linkptr = [ud.linkptr, hf];
        %         ud.link = [ud.link; Hline];
        
        % First reset the stuff to black and the same size as others.
        % Then also put the tag on there.
        for i = 1:length(dims)
            for j = i:length(dims)
                set(H(i,j),'markersize',3,'marker','o','linestyle','none',...
                    'markerfacecolor','w','color','k',...
                    'tag','black')
                set(H(j,i),'markersize',3,'marker','o','linestyle','none',...
                    'markerfacecolor','w','color','k',...
                    'tag','black')
            end
        end
        pp = length(dims);
        % just need the axes for highlighting. Do not add this to the brushing one.
        ind = sub2ind(size(ax),1:pp,1:pp);
        ax = ax(:);
        ax(ind) = [];
        % Save handles to highlighted axes in here.
        ud.highlight = [ud.highlight,ax'];
        
        set(0,'userdata',ud)

    case 2
        % Color by groups - must be loaded by the user. Not from
        % clustering.
        if isempty(ud.classlab)
            errordlg('You must load some group labels.')
            close(hf)
            return
        end
        % No variable labels with this one - histograms on diagonal.
        gplotmatrix(data(:,dims),[],ud.classlab,[],[],[],'no');
    case 3
        % Color by clusters. 
        if isempty(ud.kmeansids) & isempty(ud.agcids) & isempty(ud.mbcids)
            % haven't clustered anything yet.
            errordlg('You must create some clusters first.')
            close(hf)
            return
        end
        menustrg = [];
        cidstr = [];
        if ~isempty(ud.kmeansids)
            menustrg = [menustrg, {'k-Means Clusters'}];
            cidstr = [cidstr, {'ud.kmeansids'}];
        end
        if ~isempty(ud.agcids)
            menustrg = [menustrg, {'Agglomerative Clustering'}];
            cidstr = [cidstr, {'ud.agcids'}];
        end
        if ~isempty(ud.mbcids)
            menustrg = [menustrg, {'Model-Based Clustering'}];
            cidstr = [cidstr, {'ud.mbcids'}];
        end
        if length(cidstr) == 1
            % no need for a listbox. Just plot.
            eval(['gplotmatrix(data(:,dims),data(:,dims), ' cidstr{1} ' );'])
        else
            [sel,ok] = listdlg('PromptString','Select a type of clustering:',...
                'SelectionMode','single',...
                'ListString',menustrg);
            if ok == 1
                % person selected something.
                eval(['gplotmatrix(data(:,dims),data(:,dims), ' cidstr{sel} ' );'])
            end
            
        end
end


%%%%%%%%%%%%%%%%%%%%%%%%%
function brushlink
% This function will not do any color stuff, so no need to worry about
% color, brushing or linking.
% NOTE that this plot will NOT be closed with the GUI like the others.

tg = findobj('tag','gedagui');
H = get(tg,'userdata');
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
% Get the dataset to be used.
tmp = get(H.data,'string');
dataset = tmp{get(H.data,'value')};
switch dataset
    case 'X'
        % use the original data ud.X
        data = ud.X;
        xstr = 'X';
    case 'PCA'
        % use PCA field. this is the projection matrix so data =
        % ud.X*ud.pca(:,1:d). 
        data = ud.X*ud.pca;
        xstr = 'PCA';

    case 'LLE'
        data = ud.LLE;
        xstr = 'LLE';
    case 'HLLE'
        data = ud.hLLE;
        xstr = 'HLLE';
    case 'ISOMAP'
        % Check to see what is saved there. Might be the whole thing or
        % might be just what the user outputs. Depends on whether the other
        % gui is open or not.
        % if iscell - then get the right number of dimensions wanted - like
        % pca. else it is double - correct array to just use.
        [n,p] = size(ud.X);
        if ~iscell(ud.isomap)
            data = ud.isomap;
        else
            data = ud.isomap{end}';
        end
        xstr = 'ISOMAP';
                
    case 'MDS'
        % Added 11-12-05 - Process the MDS data.
        data = ud.mds;
        xstr = 'MDS';
        
    case 'CMDS'
        % Added 11-12-05 - Process the CMDS data.
        data = ud.cmds;
        xstr = 'CMDS';
        
    case 'PPEDA'
        % Added 11-12-05 - Process the PPEDA data.
        Z = sphere(ud.X);
        data = Z*ud.ppeda;
        xstr = 'PPEDA';
       

end
[n,p] = size(data);
% Get the information for plotting: Dimensions to use.
tmp = get(H.dimbrush,'string');
if strcmp(lower(tmp),'all')
    % user wants all dimensions to display.
    dims = 1:p;
else
    eval(['dims = [' tmp '];']);
    dims = round(dims);
end
if any(dims < 1) | any(dims > p)
    errordlg(['Dimensions must be between 1 and ' int2str(p)])
    return
end
if length(unique(dims)) < length(dims)
    errordlg('Dimensions must be different.')
    return
end

% Set up the string array for plotting purposes.
if strcmp(dataset,'X')
    % Then we are plotting the regular data set. Just use the regular
    % labels.
    labstrg = ud.varlab(dims);
else
    % we are plotting something else - PCA, etc.
    for ii = 1:length(dims)
        labstrg{ii} = [xstr ' ' int2str(dims(ii))];
    end
end

% This function will create its own figure. Do not mess with the function -
% too many things can get messed up!!!!!
brushscatter(data(:,dims),labstrg);

% Set some housekeeping things.
hf = findobj('Name','Scatterplot Brushing');
set(hf,'numbertitle','off','name','EDA: Scatterplot Matrix Brushing')
% set(hf,'tag','brush','numbertitle','off','name','EDA: Scatterplot Matrix Brushing')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'tg = findobj(''tag'',''gedagui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DO ANDREWS CURVES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doandrews

tg = findobj('tag','gedagui');
H = get(tg,'userdata');
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
% Get the dataset to be used.
tmp = get(H.data,'string');
dataset = tmp{get(H.data,'value')};
switch dataset
    case 'X'
        % use the original data ud.X
        data = ud.X;
        xstr = 'X';
    case 'PCA'
        % use PCA field. this is the projection matrix so data =
        % ud.X*ud.pca(:,1:d). 
        data = ud.X*ud.pca;
        xstr = 'PCA';

    case 'LLE'
        data = ud.LLE;
        xstr = 'LLE';
    case 'HLLE'
        data = ud.hLLE;
        xstr = 'HLLE';
    case 'ISOMAP'
        % Check to see what is saved there. Might be the whole thing or
        % might be just what the user outputs. Depends on whether the other
        % gui is open or not.
        % if iscell - then get the right number of dimensions wanted - like
        % pca. else it is double - correct array to just use.
        [n,p] = size(ud.X);
        if ~iscell(ud.isomap)
            data = ud.isomap;
        else
            data = ud.isomap{end}';
        end
        xstr = 'ISOMAP';
        
                
    case 'MDS'
        % Added 11-12-05 - Process the MDS data.
        data = ud.mds;
        xstr = 'MDS';
        
    case 'CMDS'
        % Added 11-12-05 - Process the CMDS data.
        data = ud.cmds;
        xstr = 'CMDS';
        
    case 'PPEDA'
        % Added 11-12-05 - Process the PPEDA data.
        Z = sphere(ud.X);
        data = Z*ud.ppeda;
        xstr = 'PPEDA';
       

end
[n,p] = size(data);
% Get the information for plotting: Dimensions to use.
tmp = get(H.dimandrews,'string');
if strcmp(lower(tmp),'all')
    % user wants all dimensions to display.
    dims = 1:p;
else
    eval(['dims = [' tmp '];']);
    dims = round(dims);
end
if any(dims < 1) | any(dims > p)
    errordlg(['Dimensions must be between 1 and ' int2str(p)])
    return
end
if length(unique(dims)) < length(dims)
    errordlg('Dimensions must be different.')
    return
end
% Get the color by groups flag.
colflag = get(H.popmode,'value');
% OK to plot
hf = figure;
set(hf,'tag','andrews','numbertitle','off','name','EDA: Andrews'' Curves')
set(hf,'backingstore','off','renderer','painters','DoubleBuffer','on')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'gedagui(''update'');tg = findobj(''tag'',''gedagui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)
figure(hf)
fud = [];
switch colflag
    case 1
        % just do a plain plot
        Hline = andrews(data(:,dims),0);
        % This is a vector of handles - each observation has a handle.
        ud.linkptrap = [ud.linkptrap, hf];
        ud.linkap = [ud.linkap, Hline(:)];
        set(0,'userdata',ud)

    case 2
        % Color by groups - must be loaded by the user. Not from
        % clustering.
        if isempty(ud.classlab)
            errordlg('You must load some group labels.')
            close(hf)
            return
        end
        andrews(data(:,dims),1,ud.classlab);
    case 3
        % Color by clusters. 
        if isempty(ud.kmeansids) & isempty(ud.agcids) & isempty(ud.mbcids)
            % haven't clustered anything yet.
            errordlg('You must create some clusters first.')
            close(hf)
            return
        end
        menustrg = [];
        cidstr = [];
        if ~isempty(ud.kmeansids)
            menustrg = [menustrg, {'k-Means Clusters'}];
            cidstr = [cidstr, {'ud.kmeansids'}];
        end
        if ~isempty(ud.agcids)
            menustrg = [menustrg, {'Agglomerative Clustering'}];
            cidstr = [cidstr, {'ud.agcids'}];
        end
        if ~isempty(ud.mbcids)
            menustrg = [menustrg, {'Model-Based Clustering'}];
            cidstr = [cidstr, {'ud.mbcids'}];
        end
        if length(cidstr) == 1
            % no need for a listbox. Just plot.
            eval(['andrews(data(:,dims),1, ' cidstr{1} ' );'])
        else
            [sel,ok] = listdlg('PromptString','Select a type of clustering:',...
                'SelectionMode','single',...
                'ListString',menustrg);
            if ok == 1
                % person selected something.
                eval(['andrews(data(:,dims),1, ' cidstr{sel} ' );'])
            end
            
        end
end
title(xstr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function Hline = andrews(data,colflag,g)
% Hline is a vector of line handles.
% g is a vector of class labels.
[n,p] = size(data);

% THe following gets the axis lines.
% axis off
hax = axes('position',[0.05 0.075 0.9  0.8]);
set(hax,'visible','off')
set(hax,'xlimmode','manual')
set(hax,'xlim',[-pi pi])
axis off

% Set up the line handles - need n of these
Hline = zeros(1,n);
for i = 1:n
    Hline(i) = line('xdata',nan,'ydata',nan,'linestyle','-');
end

theta = -pi:0.1:pi;    %this defines the domain that will be plotted
y = zeros(n,p);       %there will n curves plotted, one for each obs
ang = zeros(length(theta),p);   %each row must be dotted w/ observation
% Get the string to evaluate function.
fstr = ['[1/sqrt(2) '];   %Initialize the string.
for i = 2:p
    if rem(i,2) == 0
        fstr = [fstr,' sin(',int2str(i/2), '*i) '];
    else
        fstr = [fstr,' cos(',int2str((i-1)/2),'*i) '];
    end
end
fstr = [fstr,' ]'];
k=0;
% evaluate sin and cos functions at each angle theta
for i=theta
    k=k+1;
    ang(k,:)=eval(fstr);
end
% inside the funciton.

% Now generate a y for each observation
for i=1:n     %loop over each observation
    for j=1:length(theta)
        y(i,j)=data(i,:)*ang(j,:)'; 
    end
end
% Display the curve
if colflag == 0
    % then display without class colors
    for i=1:n
        set(Hline(i),'xdata',theta,'ydata',y(i,:));
    end
elseif colflag == 1
    % then display WITH group colors.
    % Can only display up to 7 groups by color. this should be sufficient.
    % We will use the default MATLAB colors
    cols = {'b';'g';'r';'c';'m';'y';'k'};
    clab = unique(g);
    if length(clab) > length(cols)
        errordlg('The maximum number of allowed groups is 7.')
        return
    end
    for k = 1:length(clab)
        % loop over all of the different colors and display
        inds = find(g==clab(k));
        for i=1:length(inds)
            set(Hline(inds(i)),'xdata',theta,'ydata',y(inds(i),:),'color',cols{k});
        end  
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DO PARALLEL COORDINATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doparallel

tg = findobj('tag','gedagui');
H = get(tg,'userdata');
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load some data first.')
    return
end
% Get the dataset to be used.
tmp = get(H.data,'string');
dataset = tmp{get(H.data,'value')};
switch dataset
    case 'X'
        % use the original data ud.X
        data = ud.X;
        xstr = 'X';
    case 'PCA'
        % use PCA field. this is the projection matrix so data =
        % ud.X*ud.pca(:,1:d). 
        data = ud.X*ud.pca;
        xstr = 'PCA';

    case 'LLE'
        data = ud.LLE;
        xstr = 'LLE';
    case 'HLLE'
        data = ud.hLLE;
        xstr = 'HLLE';
    case 'ISOMAP'
        % Check to see what is saved there. Might be the whole thing or
        % might be just what the user outputs. Depends on whether the other
        % gui is open or not.
        % if iscell - then get the right number of dimensions wanted - like
        % pca. else it is double - correct array to just use.
        [n,p] = size(ud.X);
        if ~iscell(ud.isomap)
            data = ud.isomap;
        else
            data = ud.isomap{end}';
        end
        xstr = 'ISOMAP';
                       
    case 'MDS'
        % Added 11-12-05 - Process the MDS data.
        data = ud.mds;
        xstr = 'MDS';
        
    case 'CMDS'
        % Added 11-12-05 - Process the CMDS data.
        data = ud.cmds;
        xstr = 'CMDS';
        
    case 'PPEDA'
        % Added 11-12-05 - Process the PPEDA data.
        Z = sphere(ud.X);
        data = Z*ud.ppeda;
        xstr = 'PPEDA';
       
end
[n,p] = size(data);
% Get the information for plotting: Dimensions to use.
tmp = get(H.dimparallel,'string');
if strcmp(lower(tmp),'all')
    % user wants all dimensions to display.
    dims = 1:p;
else
    eval(['dims = [' tmp '];']);
    dims = round(dims);
end
if any(dims < 1) | any(dims > p)
    errordlg(['Dimensions must be between 1 and ' int2str(p)])
    return
end
if length(unique(dims)) < length(dims)
    errordlg('Dimensions must be different.')
    return
end
% Get the color by groups flag.
colflag = get(H.popmode,'value');
% OK to plot
hf = figure;
set(hf,'tag','parallel','numbertitle','off','name','EDA: Parallel Coordinates')
set(hf,'backingstore','off','renderer','painters','DoubleBuffer','on')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'gedagui(''update'');tg = findobj(''tag'',''gedagui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)
figure(hf)
fud = [];
switch colflag
    case 1
        % just do a plain plot
        Hline = parallel(data(:,dims),0);
        % This is a vector of handles - each observation has a handle.
        ud.linkptrap = [ud.linkptrap, hf];
        ud.linkap = [ud.linkap, Hline(:)];
        set(0,'userdata',ud)

    case 2
        % Color by groups - must be loaded by the user. Not from
        % clustering.
        if isempty(ud.classlab)
            errordlg('You must load some group labels.')
            close(hf)
            return
        end
        parallel(data(:,dims),1,ud.classlab);
    case 3
        % Color by clusters. 
        if isempty(ud.kmeansids) & isempty(ud.agcids) & isempty(ud.mbcids)
            % haven't clustered anything yet.
            errordlg('You must create some clusters first.')
            close(hf)
            return
        end
        menustrg = [];
        cidstr = [];
        if ~isempty(ud.kmeansids)
            menustrg = [menustrg, {'k-Means Clusters'}];
            cidstr = [cidstr, {'ud.kmeansids'}];
        end
        if ~isempty(ud.agcids)
            menustrg = [menustrg, {'Agglomerative Clustering'}];
            cidstr = [cidstr, {'ud.agcids'}];
        end
        if ~isempty(ud.mbcids)
            menustrg = [menustrg, {'Model-Based Clustering'}];
            cidstr = [cidstr, {'ud.mbcids'}];
        end
        if length(cidstr) == 1
            % no need for a listbox. Just plot.
            eval(['parallel(data(:,dims),1, ' cidstr{1} ' );'])
        else
            [sel,ok] = listdlg('PromptString','Select a type of clustering:',...
                'SelectionMode','single',...
                'ListString',menustrg);
            if ok == 1
                % person selected something.
                eval(['parallel(data(:,dims),1, ' cidstr{sel} ' );'])
            end
            
        end
end
title(xstr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Hline = parallel(x,colflag,g)
% Hline is a vector of handles to lines - for brushing/linking
% colflag is a flag indicating color by groups.
% g is a vector of group labels.
[n,p] = size(x);
% Calling part
% Set up the line handles - need n of these
Hline = zeros(1,n);
for i = 1:n
    Hline(i) = line('xdata',nan,'ydata',nan,'linestyle','-');
end
% get the axes lines
ypos = linspace(0,1,p);
xpos = [0 1];
% THe following gets the axis lines.
% Save the text handles, so they can be permuted, too.
% Save the text strings, too.
Htext = zeros(1,p);
k = p;
for i=1:p            
    line(xpos,[ypos(i) ypos(i)],'color','k')
    Htext(i) = text(-0.05,ypos(i), ['x' num2str(k)]);
    k=k-1;
end
axis off
% parallel(Hline,X,Htext,1:p);

% Inside the funciton.

% If parallel coordinates, then change range.
% map all values onto the interval 0 to 1
% lines will extend over the range 0 to 1
md = min(x(:)); % find the min of all the data
rng = range(x(:));  %find the range of the data
xn = (x-md)/rng;
[n,p] = size(x);
ypos = linspace(0,1,p);
if colflag == 0
    % then display without class colors
    for i=1:n
        set(Hline(i),'xdata',xn(i,:),'ydata',fliplr(ypos))
    end   
elseif colflag == 1
    % then display WITH group colors.
    % Can only display up to 7 groups by color. this should be sufficient.
    % We will use the default MATLAB colors
    cols = {'b';'g';'r';'c';'m';'y';'k'};
    clab = unique(g);
    if length(clab) > length(cols)
        errordlg('The maximum number of allowed groups is 7.')
        return
    end
    for k = 1:length(clab)
        % loop over all of the different colors and display
        inds = find(g==clab(k));
        
        try
            for i=1:length(inds)
                set(Hline(inds(i)),'xdata',xn(inds(i),:),'ydata',fliplr(ypos),'color',cols{k})
            end
        catch
            keyboard
        end

    end
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Z = sphere(X)
% This function will sphere the data. This means the data will now have a
% mean of 0 and a covariance matrix of 1.
[n,p] = size(X);
muhat = mean(X);
[V,D] = eig(cov(X));
Xc = X - ones(n,1)*muhat;
Z = ((D)^(-1/2)*V'*Xc')';
