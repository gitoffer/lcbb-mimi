function brushgui(arg)
% BRUSHGUI Brushing and Labeling GUI
%
% This GUI function allows one to brush plots and see the corresponding 
% plots highlighted in the other open plots. These plots must be called
% from the EDA GUIs.
%
% Brushable plots: 2-D scatterplot, ReClus, rectangle plot
% Linkable plots: brushable plots, Andrews' curves, parallel coordinates,
%                   3-D scatterplot, scatterplot matrix.
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% Find out if the gedagui is open. The only way they can brush and link is
% if that gui is open. If not, provide an error message.
Hgeda = findobj('tag','gedagui');
if isempty(Hgeda)
    errordlg('The Graphical EDA GUI must be open to brush and link plots.')
    return
end

% First set up the layout if it does not exist.
flg = findobj('tag','brushgui');
if isempty(flg)
    % then create the gui
    brushlayout
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'brushplot')
    % Execute button from brush frame
    H = get(flg,'userdata');
    if ~isempty(H.Hbrush)
        resetplots
    end
    brushplot
    
elseif strcmp(arg,'createbrush')
    H = get(flg,'userdata');
    CreateBrushButtDwn(H,flg)
    
elseif strcmp(arg,'BrushButtDwn')
    % User has clicked on the brush.
    % Set the function for brush motion.
    set(gcf,'WindowButtonMotionFcn','brushgui(''movebrush'')')
    % Set the function for when the user clicks up on the brush.
    set(gcf,'WindowButtonUpFcn','brushgui(''movebrushbuttup'')')
    set(gcf,'Pointer','fleur');
    
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
    
elseif strcmp(arg,'color')
    % This returns the chosen color for all frames. 
    H = get(flg,'userdata');
    % Note that if the user hits the cancel button, then the value in the
    % field is 0. Use this for error checking.
    H.color = uisetcolor([1 0 0],'Choose the color:');
    set(flg,'userdata',H)
    
elseif strcmp(arg,'groupcolor')
    % This one colors the selected group with the selected color.
    H = get(flg,'userdata');
    if ~isempty(H.Hbrush)    
        resetplots    
    end
    groupcolor(H);
    
elseif strcmp(arg,'obscolor')
    % This one colors the selected observation with the chosen color.
    H = get(flg,'userdata');
    if ~isempty(H.Hbrush) 
        resetplots
    end
    obscolor(H)
        
elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','brushgui');
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
tg = findobj('tag','brushgui');
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
set(Hax,'buttondown','brushgui(''createbrush'')','drawmode','fast')
% Reset the handle to the current brushable plot.
H.brushplot = ud.brushptr(bplot);
set(tg,'userdata',H)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resetplots
% Reset all plots to their original color - black
Hgui = findobj('tag','brushgui');
H = get(Hgui,'userdata');
ud = get(0,'userdata');
hndls = findobj('tag','high');
delete(hndls)

% for ii = 1:length(ud.highlight)
%     set(ud.highlight(ii),'xdata',nan,'ydata',nan)
% end
set(ud.linkap,'color','k')
% % delete the brush
delbrush

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function delbrush
Hgui = findobj('tag','brushgui');
H = get(Hgui,'userdata');
ud = get(0,'userdata');
if ~isempty(H.Hbrush) & ishandle(H.Hbrush)
    delete(H.Hbrush);
end
H.Hbrush = [];
set(Hgui,'userdata',H)
movebrushbuttup


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function groupcolor(H)
% This is executed when the person clicks on 'execute' button for Color the
% Groups.
% H is the structure to the brushgui userdata

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
% H is the structure to the brushgui userdata
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
% H is a structure saved in tg's userdata. This is really the brushgui
% userdata. tg is the handle to brushgui.
% Create a brush.

if ~isempty(H.Hbrush)
    % Delete the current brush.
    delete(H.Hbrush)
end
H.Hbrush = line('xdata',nan,'ydata',nan,'parent',gca,'visible','off',...
    'erasemode','xor',...
    'color','r','linewidth',2,'buttondown','brushgui(''BrushButtDwn'')');
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
ud = get(0,'userdata');
Haxs = get(ud.brushptr,'children');
for i = 1:length(Haxs)
    if iscell(Haxs)
        set(Haxs{i},'buttondown','')
    else
        set(Haxs(i),'buttondown','')
    end
end
% Highlight the points inside the brush.
UpdateHighlight(H)
set(tg,'userdata',H)

%%%%%%%%%%   movebrushbuttup    %%%%%%%%%%%%%%%%%%%%%%%%%%
function movebrushbuttup
% Reset the window functions.

% Get the plot that is brushable.
ud = get(0,'userdata');

tg = findobj('tag','brushgui');
H = get(tg,'userdata'); % userdata for this gui.
bplot = get(H.popplot,'value');

if ~isempty(ud.brushptr)
    set(ud.brushptr(bplot),'WindowButtonMotionFcn','')
    set(ud.brushptr(bplot),'WindowButtonUpFcn','')
    set(ud.brushptr(bplot),'Pointer','arrow')
end

%%%%%%      MoveBrush           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MoveBrush
% get handle
Hgui = findobj('tag','brushgui');
H = get(Hgui,'userdata');
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
ud = get(0,'userdata');
% Get the info to do the brushing.
tg = findobj('tag','brushgui');
H = get(tg,'userdata'); % userdata for this gui.
% Get the brush mode: 1 = transient, 2 = lasting.
mode = get(H.popmode,'value');
if mode == 1
    H.mode = 'transient';
    hndls = findobj('tag','high');
    delete(hndls)
elseif mode == 2
    H.mode = 'lasting';
else
    H.mode = 'undo';    % this un-highlights individual points.
end
set(tg,'userdata',H)
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
bplot = get(H.popplot,'value');
XX = get(ud.brush(bplot),'xdata');
YY = get(ud.brush(bplot),'ydata');
n = length(XX);
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
            for ii = 1:length(ud.highlight)
                % find all of the highlighted ones and delete them.
                Hhigh = line('xdata',nan,'ydata',nan,...
                    'markersize',3,'marker','o','linestyle','none',...
                    'tag','high');     % Placeholder for highlighted points.   
                % reset to the correct axes.
                set(Hhigh,'parent',ud.highlight(ii));
                % Find the children - both lines - need to get to the
                % actual data.
                Hline = findobj(ud.highlight(ii),'tag','black');
                Xp = get(Hline,'xdata');
                Yp = get(Hline,'ydata');
                % plot highlighted points
                set(Hhigh,'xdata',Xp(insidebrush),...
                    'ydata',Yp(insidebrush),...
                    'markerfacecolor',H.color);
            end
            % Set the selection value in the observation list box to the
            % ones that are inside the brush.
            set(H.listcase,'value',insidebrush);

        end % if isempty 
        % Now need to highlight the open Andrews' curves plots and parallel
        % coordinate plots.
        if ~isempty(insidebrush) & ~isempty(ud.linkptrap)
            % Then there are parallel and/or Andrews plots.
            set(ud.linkap(outsidebrush,:),'color','k')
            set(ud.linkap(insidebrush,:),'color',H.color)
        elseif ~isempty(ud.linkptrap)
            % plots exist, could be points outside brush that need to be
            % changed to black.
            set(ud.linkap,'color','k')
        end
    case 'lasting'
        % Once points are brushed, they stay brushed. Just take the inside
        % points and make them red. Those outside stay the same.
        % For scatterplots, we will find the old red data values and add
        % the inside ones to the old ones. Make them red.
        if ~isempty(insidebrush)
            % Scatterplot ones first.
            for ii = 1:length(ud.highlight)
                % Find original data.
                Hline = findobj(ud.highlight(ii),'tag','black');
                Xp = get(Hline,'xdata');   % This is the full data set.
                Yp = get(Hline,'ydata');
                % Now find ones already highlighted this color in this axes.
                Hhigh = findobj('tag','high');
                Hchild = get(ud.highlight(ii),'children');
                Hint = intersect(Hhigh,Hchild);
                Hhigh = findobj(Hint,'markerfacecolor',H.color);
                if isempty(Hhigh)
                    % Then set up new line with that color.
                    Ht = line('xdata',Xp(insidebrush),'ydata',Yp(insidebrush),...
                        'markersize',3,'marker','o','linestyle','none',...
                        'tag','high',...
                        'markerfacecolor',H.color);     % Placeholder for highlighted points. 
                    set(Ht,'parent',ud.highlight(ii));
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
            

            
            % Now need to highlight the open Andrews' curves plots and parallel
            % coordinate plots.
            if ~isempty(insidebrush) & ~isempty(ud.linkptrap)
                % Then there are parallel and/or Andrews plots.
                % find the ones that are black.
                set(ud.linkap(insidebrush,:),'color',H.color)
            end
            
        end % if isempty 
        
    case 'undo'
        % Once points are brushed, are turned black.
        if ~isempty(insidebrush)
            % Scatterplot ones first.
            for ii = 1:length(ud.highlight)
                % Find original data.
                Hline = findobj(ud.highlight(ii),'tag','black');
                Xp = get(Hline,'xdata');   % This is the full data set.
                Yp = get(Hline,'ydata');
                
                % These are highlighted points - inside brush.
                Xpin = Xp(insidebrush);
                Ypin = Yp(insidebrush);
                obsin = [Xpin(:) Ypin(:)];
                
                % Now find all lines already highlighted on this axes.
                Hhigh = findobj(ud.highlight(ii),'tag','high');
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
            % Now need to highlight the open Andrews' curves plots and parallel
            % coordinate plots.
            if ~isempty(insidebrush) & ~isempty(ud.linkptrap)
                % Then there are parallel and/or Andrews plots.
                % find the ones that are black.
                set(ud.linkap(insidebrush,:),'color','k')
            end
        end % if isempty         
end



