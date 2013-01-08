function brushscatter(arg,labs)
%   BRUSHSCATTER    Scatterplot Brushing and Linking
%
%   BRUSHSCATTER(X,LABS)
%   X is an n x p matrix of data values. LABS is an optional input argument
%   containing the variable labels. This must be a p-dimensional cell array
%   of strings.
%
%   To craete a brush: put the cursor in any scatterplot. Hold the left
%   mouser button and drag to create a brush. 
%
%   To brush points: Click on the brush outline, hold the left mouse button
%   and drag the brush.
%
%   For a menu of other options: Click on any diagonal plot using the righ
%   mouse button. A menu of options will appear.
%
%
%   Exploratory Data Analysis Toolbox, V2, December 2006
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

if nargin==2
    % First one contains data - initialize figure.
    X = arg;
    arg = 'init';
    [n,p] = size(X);
    if length(labs) ~= p
        error('Array of variable names is wrong dimensionality')
        return
    end
    if ~iscell(labs)
        error('Array of variable names must be a cell array of strings.')
        return
    end
elseif nargin==1 && isnumeric(arg)
    % Called only with the data. Initialize the figure and use generic
    % variable names.
    X = arg;
    arg = 'init';
    % Get some generic names.
    [n,p] = size(X);
    for i = 1:p
        labs{i} = ['Variable ' int2str(i)];
    end
end   
    

if strcmp(arg,'brushplot')
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    
    % Execute button from brush frame
    if ~isempty(H.Hbrush)
        resetplots
    end
    brushplot
    
elseif strcmp(arg,'init')
    % create the scatterplot
    init(X,labs)
    
elseif strcmp(arg,'createbrush')
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    
    CreateBrushButtDwn(H,tg)
    
elseif strcmp(arg,'BrushButtDwn')
    % User has clicked on the brush.
    % Set the function for brush motion.
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    set(H.fig,'WindowButtonMotionFcn','brushscatter(''movebrush'')')
    % Set the function for when the user clicks up on the brush.
    set(H.fig,'WindowButtonUpFcn','brushscatter(''movebrushbuttup'')')
    set(H.fig,'Pointer','fleur');
    
elseif strcmp(arg,'movebrush')
    % When brush moves - call update function.   
    MoveBrush
    
elseif strcmp(arg,'movebrushbuttup')
    % User finished moving the brush - let up on the button.
    % Reset the windows functions.
    movebrushbuttup

elseif strcmp(arg,'reset')
    % This resets all plots to their original color. 
    % used with all frames
    resetplots
    
elseif strcmp(arg,'delbrush')
    % This deletes the brush.
    % Gets rid of the brush handles, etc.
    delbrush

%%%%%%%%%%%%%%%%%%%%  from here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
elseif strcmp(arg,'delete')
    % Operation is to delete points. Need to reset the menu items.
    % Also need to re-do the axes, after the point(s) is deleted.
    % this operation only makes sense with the 'lasting' mode.
    % Delete won't really take into account the mode.
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    H.operation = 'delete';
    set(H.MenDel,'checked','on')
    set(H.MenHigh,'checked','off')
    set(H.fig,'userdata',H)
    
elseif strcmp(arg,'highlight')
    % Operation is to highlight points. Change the marker to filled 
    % and another color - maybe red. Adjust menu items. This operation
    % can be any of the 3 modes. 
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    H.operation = 'highlight';
    set(H.MenHigh,'checked','on')
    set(H.MenDel,'checked','off')
    set(H.fig,'userdata',H)

elseif strcmp(arg,'transient')
    % Set the flag to transient.
    % Set the check in menu to transient.
    % Set the others to uncheck.
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    set(H.MenTrans,'checked','on')
    H.mode = 'transient';
    set([H.MenLast,H.MenUndo],'checked','off')
    set(H.fig,'userdata',H)
  
elseif strcmp(arg,'lasting')
    % SAB, except for lasting.
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    set(H.MenLast,'checked','on')
    H.mode = 'lasting';
    set([H.MenTrans,H.MenUndo],'checked','off')
    set(H.fig,'userdata',H)
    
elseif strcmp(arg,'undo')
    % SAB, except for undo.
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    set(H.MenUndo,'checked','on')
    H.mode = 'undo';
    set([H.MenTrans,H.MenLast],'checked','off')
    set(H.fig,'userdata',H)
    
elseif strcmp(arg,'resetfig')
    % Reset the figure to initial state.
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    resetplots
    
%%%%%%%%%%%%   TO HERE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  were added back from the old brushscatter to the new version
        
elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','brushscatter');
    H = get(tg,'userdata');
    ud = get(0,'userdata');
    resetplots
    movebrushbuttup
    Haxs = get(ud.brushptr,'children');
    for i = 1:length(Haxs)
        if iscell(Haxs)
            set(Haxs{i},'buttondown','')
        else
            set(Haxs(i),'buttondown','')
        end
    end
    delete(tg)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function brushplot
% This brings up the selected plot to brush.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data and plot first.')
    return
end
if isempty(ud.brushptr)
    errordlg('You must have some plots open to brush.')
    return
end
tg = findobj('tag','brushscatter');
H = get(tg,'userdata'); % userdata for this gui.
% Reset everything - including the buttondown function for axes
resetplots
Haxs = get(ud.brushptr,'children');
for i = 1:length(Haxs)
    if iscell(Haxs)
        set(Haxs{i},'buttondown','')
    else
        set(Haxs(i),'buttondown','')
    end
end
% Get the brush mode: 1 = transient, 2 = lasting.
mode = get(H.popmode,'value');
if mode == 1
    H.mode = 'transient';
elseif mode == 2
    H.mode = 'lasting';
else
    H.mode = 'undo';    % this un-highlights individual points.
end
% Get the plot to brush. This SHOULD be index to the brush pointer.
bplot = get(H.popplot,'value');
figure(ud.brushptr(bplot))
Hax = get(ud.brushptr(bplot),'children');
% This figure is made active. ONLY this plot has the ability to draw a
% brush.
set(Hax,'buttondown','brushscatter(''createbrush'')','drawmode','fast')
% Reset the handle to the current brushable plot.
H.brushplot = ud.brushptr(bplot);
set(tg,'userdata',H)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resetplots
% Reset all plots to their original color - black
% Hgui = findobj('tag','brushscatter');
% H = get(Hgui,'userdata');

hndls = findobj('tag','high');
delete(hndls)

% for ii = 1:length(ud.highlight)
%     set(ud.highlight(ii),'xdata',nan,'ydata',nan)
% end

% % delete the brush
delbrush

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function delbrush
Hgui = findobj('tag','brushscatter');
H = get(Hgui,'userdata');
ud = get(0,'userdata');
if ~isempty(H.Hbrush) & ishandle(H.Hbrush)
    delete(H.Hbrush);
end
H.Hbrush = [];
set(Hgui,'userdata',H)
movebrushbuttup
% Reset everything - including the buttondown function for axes
% Haxs = get(ud.brushptr,'children');
% for i = 1:length(Haxs)
%     if iscell(Haxs)
%         set(Haxs{i},'buttondown','')
%     else
%         set(Haxs(i),'buttondown','')
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function groupcolor(H)
% This is executed when the person clicks on 'execute' button for Color the
% Groups.
% H is the structure to the brushscatter userdata

ud = get(0,'userdata');
% Find the group that has been selected.
grpstrg = get(H.listgroup,'string'); 
grp = get(H.listgroup,'value');
if strcmp(grpstrg(grp),'None')
    errordlg('You must load up some class labels first.')
    return
end
% H.color, ud.classlab
% Find the indices to the observations belonging to the selected group.
if iscell(grpstrg)
    tmp = str2num(grpstrg{grp});
else
    tmp = str2num(grpstrg(grp));
end
inds = find(ud.classlab == tmp);
% Color the groups in the brushable plots
for ii = 1:length(ud.highlight)
    axes(ud.highlight(ii));
    % First get the data that are plotted there.
    Hline = findobj(ud.highlight(ii),'tag','black');
    Xp = get(Hline,'xdata');   % This is the full data set.
    Yp = get(Hline,'ydata');
    % Now color the group.
    Ht = line('xdata',Xp(inds),'ydata',Yp(inds),...
        'markersize',3,'marker','o','linestyle','none',...
        'tag','high',...
        'markerfacecolor',H.color);     % Placeholder for highlighted points. 
    set(Ht,'parent',ud.highlight(ii));
    
end
if ~isempty(ud.linkap)
    % set these to the right color.
    set(ud.linkap(inds,:),'color',H.color);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obscolor(H)
% This is executed when the person clicks on 'execute' button for Color the
% Observations.
% H is the structure to the brushscatter userdata
ud = get(0,'userdata');
% Find the observations that have been selected. 
obs = get(H.listcase,'value');
% Color the obs in the brushable plots
for ii = 1:length(ud.highlight)
    axes(ud.highlight(ii));
    % First get the data that are plotted there.
    Hline = findobj(ud.highlight(ii),'tag','black');
    Xp = get(Hline,'xdata');   % This is the full data set.
    Yp = get(Hline,'ydata');
    % Now color the group.
    Ht = line('xdata',Xp(obs),'ydata',Yp(obs),...
        'markersize',3,'marker','o','linestyle','none',...
        'tag','high',...
        'markerfacecolor',H.color);     % Placeholder for highlighted points. 
    set(Ht,'parent',ud.highlight(ii));
    
end
if ~isempty(ud.linkap)
    % set these to the right color.
    set(ud.linkap(obs,:),'color',H.color);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%     CreateBrushButtDwn  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateBrushButtDwn(H,tg)
% H is a structure saved in tg's userdata. This is really the brushscatter
% userdata. tg is the handle to brushscatter.
% Create a brush.

if ~isempty(H.Hbrush)
    % Delete the current brush.
    delete(H.Hbrush)
end
H.Hbrush = line('xdata',nan,'ydata',nan,'parent',gca,'visible','off',...
    'erasemode','xor',...
    'color','r','linewidth',2,'buttondown','brushscatter(''BrushButtDwn'')');
% Somethig like the following.
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
xx = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
yy = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
set(H.Hbrush,'xdata',xx,'ydata',yy,'visible','on','parent',gca)
H.BrushPrevX = [];
H.BrushPrevY = [];
% Highlight the points inside the brush.
UpdateHighlight(H)
set(tg,'userdata',H)

%%%%%%%%%%   movebrushbuttup    %%%%%%%%%%%%%%%%%%%%%%%%%%
function movebrushbuttup
% Reset the window functions.

tg = findobj('tag','brushscatter');
H = get(tg,'userdata'); % userdata for this gui.

% Reset the windows functions.
set(H.fig,'WindowButtonMotionFcn','')
set(H.fig,'WindowButtonUpFcn','')
set(H.fig,'Pointer','arrow')

%%%%%%      MoveBrush           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MoveBrush
% get handle
tg = findobj('tag','brushscatter');
H = get(tg,'userdata');
% The brush is in motion. Update the location of the brush.
% Then call the UpdateFunction.
if ishandle(H.Hbrush)
    Hax = get(H.Hbrush,'parent');
    cp = get(Hax,'CurrentPoint');
    
    if isempty(H.BrushPrevX);
        H.BrushPrevX = cp(1,1);
        H.BrushPrevY = cp(1,2);
    else
        % Update brush position.
        delx = cp(1,1) - H.BrushPrevX;
        dely = cp(1,2) - H.BrushPrevY;
        H.BrushPrevX = cp(1,1);
        H.BrushPrevY = cp(1,2);
        x = get(H.Hbrush,'xdata');
        y = get(H.Hbrush,'ydata');
        newx = x + delx;
        newy = y + dely;
        set(H.Hbrush,'xdata',newx,'ydata',newy);
    end
    % Call the update function to highlight points in the brush.
    UpdateHighlight(H)

end

set(H.fig,'userdata',H)


%%%%%%      UpdateHighlight   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateHighlight(H)

% First find the current axes.
Hcax = gca;
% H.mode contains the mode.
if strcmp(H.mode,'transient')
    %%%%%%%%%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % NEED TO MAKE SURE THAT I HAVE SOMETHING THAT HAS THIS TAG.
    hndls = findobj('tag','high');
    delete(hndls)
end
% In this sub-function - highlight the points according to the mode that is
% specified: transient, lasting, undo
% Get the vertices of the brush.
if ~isempty(H.Hbrush)
    xv = get(H.Hbrush,'xdata');
    yv = get(H.Hbrush,'ydata');
else
    return
end
% Find the two dimensions plotted there.
[I,J] = find(Hcax == H.Haxes);  % Gives the indices to the current axes
XX = H.data(:,H.IndX(I,J));     % Get the corresponding X and Y coordinates.
YY = H.data(:,H.IndY(I,J));
[n,p] = size(H.data);
% Find the points inside the rectangle.
insidebrush = find(inpolygon(XX,YY,xv,yv));
outsidebrush = setdiff(1:n,insidebrush);

switch H.mode
    case 'transient'
        % Find all of the points that are in the polygon given by the
        % brush. Should be able to do this for all plots with data.
        % Make those inside the brush red - those outside black.
        if ~isempty(insidebrush)
             % need to loop through all of the plots and find the x and y
            % values plotted there.
            for ii = 1:length(H.highlight)
                % find all of the highlighted ones and delete them.
                Hhigh = line('xdata',nan,'ydata',nan,...
                    'markersize',3,'marker','o','linestyle','none',...
                    'tag','high');     % Placeholder for highlighted points.   
                % reset to the correct axes.
                set(Hhigh,'parent',H.highlight(ii));
                % Find the children - both lines - need to get to the
                % actual data.
                Hline = findobj(H.highlight(ii),'tag','black');
                Xp = get(Hline,'xdata');
                Yp = get(Hline,'ydata');
                % plot highlighted points
                set(Hhigh,'xdata',Xp(insidebrush),...
                    'ydata',Yp(insidebrush),...
                    'markerfacecolor',H.color);
            end

        end % if isempty 
    case 'lasting'
        % Once points are brushed, they stay brushed. Just take the inside
        % points and make them red. Those outside stay the same.
        % For scatterplots, we will find the old red data values and add
        % the inside ones to the old ones. Make them red.
        if ~isempty(insidebrush)
            % Scatterplot ones first.
            for ii = 1:length(H.highlight)
                % Find original data.
                Hline = findobj(H.highlight(ii),'tag','black');
                Xp = get(Hline,'xdata');   % This is the full data set.
                Yp = get(Hline,'ydata');
                % Now find ones already highlighted this color in this axes.
                Hhigh = findobj('tag','high');
                Hchild = get(H.highlight(ii),'children');
                Hint = intersect(Hhigh,Hchild);
                Hhigh = findobj(Hint,'markerfacecolor',H.color);
                if isempty(Hhigh)
                    % Then set up new line with that color.
                    Ht = line('xdata',Xp(insidebrush),'ydata',Yp(insidebrush),...
                        'markersize',3,'marker','o','linestyle','none',...
                        'tag','high',...
                        'markerfacecolor',H.color);     % Placeholder for highlighted points. 
                    set(Ht,'parent',H.highlight(ii));
                else
                    % Just augment the previous ones.
                    Xphigh = get(Hhigh,'xdata');
                    Yphigh = get(Hhigh,'ydata');                % plot highlighted points
                    Xpnew = Xp(insidebrush);
                    Ypnew = Yp(insidebrush);
                    try
                        xt = [Xpnew(:); Xphigh(:)];
                        yt = [Ypnew(:); Yphigh(:)];
                    catch
                        keyboard
                    end
                    obs = unique([xt,yt],'rows');
                    % Merge the sets and plot as highlighted.
                    % plot highlighted points
                    set(Hhigh,'xdata',obs(:,1),...
                        'ydata',obs(:,2),...
                        'markerfacecolor',H.color);
                end
            end
  
        end % if isempty 
        
    case 'undo'
        % Once points are brushed, are turned black.
        if ~isempty(insidebrush)
            % Scatterplot ones first.
            for ii = 1:length(H.highlight)
                % Find original data.
                Hline = findobj(H.highlight(ii),'tag','black');
                Xp = get(Hline,'xdata');   % This is the full data set.
                Yp = get(Hline,'ydata');
                
                % These are highlighted points - inside brush.
                Xpin = Xp(insidebrush);
                Ypin = Yp(insidebrush);
                obsin = [Xpin(:) Ypin(:)];
                
                % Now find all lines already highlighted on this axes.
                Hhigh = findobj(H.highlight(ii),'tag','high');
                % Loop through all of these in case there are points with
                % more than one color inside the brush.
                for jj = 1:length(Hhigh)
                    Xphigh = get(Hhigh(jj),'xdata');
                    Yphigh = get(Hhigh(jj),'ydata');  
                    col = get(Hhigh(jj),'markerfacecolor');
                    obshigh = [Xphigh(:) Yphigh(:)];
                    obsleft = setdiff(obshigh, obsin,'rows');
                    % Merge the sets and plot as highlighted.
                    % plot highlighted points
                    set(Hhigh(jj),'xdata',obsleft(:,1),...
                        'ydata',obsleft(:,2),...
                        'markerfacecolor',col);
                end
            end

        end % if isempty         
end


%%%%%%%%%%%%%%%%%%%%%%   INITIALIZE SCATTERPLOT  %%%%%%%%%%%%%%%%%%%%%%%
function init(X,labs)
% Calling the function with the data.
% then initialize figure
H.data = X;
H.labs = labs;
% Set up figure that is maximized.
H.fig = figure('units','normalized',...
    'position',  [0 0.0365 0.9678 0.8750],...
    'toolbar','none',...
    'menubar','none',...
    'numbertitle','off',...
    'Name','Scatterplot Brushing: Right-click on diagonal square for menu of options. Left-click and drag on any scatterplot to create a brush.',...
    'RendererMode','manual',...
    'backingstore','off',...
    'renderer','painters',...
    'DoubleBuffer','on',...
    'tag','brushscatter');
% Set up handle for context menu associated with axes.
H.cmenu = uicontextmenu;
H.MenHigh = uimenu(H.cmenu,'Label','Highlight',...
    'checked','on',...
    'callback','brushscatter(''highlight'')');   % Default brushing mode.
H.MenDel = uimenu(H.cmenu,'Label','Delete',...
    'checked','off',...
    'callback','');
%         'callback','brushscatter(''delete'')');
H.operation = 'highlight';
% Above are the operations. Below are the modes.
% These callbacks should not activate anything.
% They should re-set a MODE FLAG and check/uncheck the item.
% They MOVE BRUSH code will check to see what is
% selected here.
H.MenTrans = uimenu(H.cmenu,'Label','Transient',...
    'separator','on',...
    'checked','on',...
    'callback','brushscatter(''transient'')');
H.MenLast = uimenu(H.cmenu,'Label','Lasting',...
    'checked','off',...
    'callback','brushscatter(''lasting'')');
H.MenUndo = uimenu(H.cmenu,'Label','Undo',...
    'checked','off',...
    'callback','brushscatter(''undo'')');
H.mode = 'transient';
H.MenBrushOff = uimenu(H.cmenu,'Label','Delete Brush',...
    'separator','on',...
    'callback','brushscatter(''delbrush'')');
H.MenResetFig = uimenu(H.cmenu,'Label','Reset Figure',...
    'separator','on',...
    'callback','brushscatter(''resetfig'')');
[n,p] = size(X);
minx = min(X);
maxx = max(X);
rngx = range(X);
% set up the axes
H.IndX = zeros(p,p);    % X dim for data
H.IndY = zeros(p,p);    % Y dim for data
H.AxesLims = cell(p,p); % Axes limits.
H.Haxes = zeros(p,p);   % Axes handles.
H.HlineHigh = zeros(p,p);  % Line handles to highlighted data.
H.HlineReg = zeros(p,p);    % Line handles to non-highlighted data.
H.Inside = [];          % Indices to currently marked points. Need this for lasting mode.
% Order of axes is left-right, top-bottom
% Take up the entire figure area with axes.

I = 0; J = 0;
for j = (p-1):-1:0
    I = I + 1;
    for i = 0:(p-1)
        J = J + 1;
        pos = [i/p j/p 1/p 1/p];
        pos = floor(pos*100)/100;
        H.Haxes(I,J) = axes('pos',[i/p j/p 1/p 1/p]);
        box on
                
        if I~=J
                       
            % The following is the column index (to data) for the X and Y
            % variables.
            H.IndX(I,J) = J;
            H.IndY(I,J) = I;

            % Do the scatterplot.
            Hline = plot(X(:,J),X(:,I),'ko');
            set(gca,'yticklabel','','xticklabel','','ticklength',[0 0],...
                'buttondownfcn','brushscatter(''createbrush'')',...
                'drawmode','fast')
            % This is for brushing/linking.
            % Default color and 'undo' color is black!
            % Non-highlighted data will have a tag of 'black'
            set(Hline,'markersize',3,'marker','o','linestyle','none',...
                'markerfacecolor','w',...
                'tag','black')
            % NOTE: one handle per line. Access color of individual points by
            % the 'xdata' and 'ydata' indices.

            ax = axis;
            axis([ax(1)-rngx(J)*.05 ax(2)*1.05 ax(3)-rngx(I)*.05 ax(4)*1.05])
            H.AxesLims{I,J} = axis;
            axis manual
           
        else
            set(gca,'uicontextmenu',H.cmenu,...
                'Yticklabel','','xticklabel','',...
                'ticklength',[0 0])
            % This is a center axes - plot the variable name.
            text(0.35,0.45,labs{I})
            text(0.05,0.05,num2str(minx(I)))
            text(0.9,0.9,num2str(maxx(I)))
            axis([0 1 0 1])
            H.AxesLims{I,J} = [0 1 0 1];
        end  % if stmt
    end   % for j loop
    J = 0;
end   % for i loop
% Brush Information.
H.Hbrush = [];
H.BrushPrevX = [];
H.BrushPrevY = [];

H.CurrAxes = H.Haxes(1);

% Save all of the highlight-able axes in a vector. 
[I,J] = size(H.Haxes);
k = 0;
for i = 1:I
    for j = 1:J
        if i ~= j
            k = k + 1;
            H.highlight(k) = H.Haxes(i,j);
        end
    end
end

% Set the color to red.
H.color = [1 0 0];

set(H.fig,'UserData',H)

    
