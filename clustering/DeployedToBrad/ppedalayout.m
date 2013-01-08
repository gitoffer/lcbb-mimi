function ppedalayout
% This function will layout the gui controls. Eventually, this will be
% included in the complete function. Just have it now for simplicity.

% First get the user data from the root. See if anything is stored there.

% H.fig       Handle to GUI figure window
% H.axproj    Handle to axes to show projection - 2D scatterplot
% H.axindex   Handle to axes to show projection pursuit index
% H.step      Handle to edit box with step size. Default is 0.01
% H.trials    Handle to edit box with number of trials. Default is 4
% H.nohits    Handle to edit box with number of times we have no improvement - then change neighborhood
% H.index     Handle to popupmenu with type of index
%             {'Chi-square','Moment'});


ud = get(0,'userdata');

H.fig = figure('Tag','ppedagui',...
    'position',[150 150 726 524],...
    'resize','off',...
    'toolbar','none',...
    'menubar','none',...
    'numbertitle','off',...
    'name','Projection Pursuit EDA GUI',...
    'CloseRequestFcn','ppedagui(''close'')');

if strcmp(version('-release'),'14')
    set(0,'DefaultUicontrolFontname','Sans Serif');
end

if ~isempty(ud)
    % Then something is there already. Add necessary handles to the
    % structure. 
    ud.guis = [ud.guis(:); H.fig];
else
    % Set the usual stuff and save in root.
    ud = userdata;
    set(0,'userdata',ud)
end

%%%%%%%  FRAMES %%%%%%%%%%%%%%%
% set up all of the frames first.
uicontrol(H.fig, 'style','frame',...
    'position',[10 10 710 125]);

%%%%%%      AXES    %%%%%%%%%%%%%%%%%
% Set up the two axes for plots.

H.axindex = axes('position',[0.04 0.3 0.45 0.56]);
set(H.axindex,'fontsize',8,'box','on');
set(H.axindex,'xtick',0,'ytick',0);
set(H.axindex,'xticklabel' ,' ' ,'yticklabel',' ');
Hxlab = xlabel('Iteration Number','units','pixels');
set(Hxlab,'position',[162   -5     0])
Hylab = ylabel('Index Value','units','pixels');
set(Hylab,'position', [-5   147     0])
% axis off



H.axproj = axes('position',[0.515 0.3 0.45 0.56]);
set(H.axproj,'fontsize',8,'box','on');
set(H.axproj,'xtick',0,'ytick',0);
set(H.axproj,'xticklabel',' ', 'yticklabel',' ');
% axis off


%%%%%%% TEXT BOXES %%%%%%%%%%%%%%
% set up all of the text boxes
uicontrol(H.fig,'style','text',...
    'position',[170 495 330 27],...
    'fontweight','bold',...
    'fontsize',14,...
    'backgroundcolor',[.8 .8 .8],...
    'string','Projection Pursuit EDA')


% Instruction text boxes:

uicontrol(H.fig,'style','text',...
    'position',[145 455 450 40],...
    'horizontalalignment','left',...
    'backgroundcolor',[.8 .8 .8],...
    'string','Use this GUI to find interesting projections in 2-D. See the command window for progress. The plot on the left shows the projection pursuit index. On the right is a scatterplot of the current best plane.')

% Steps - text in frame 
uicontrol(H.fig,'style','text',...
    'position',[20 105 100 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','1. Neighborhood:')

uicontrol(H.fig,'style','text',...
    'position',[127 105 130 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','2. Number of trials:')

uicontrol(H.fig,'style','text',...
    'position',[252 105 130 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','3. Number of no-hits:')

uicontrol(H.fig,'style','text',...
    'position',[390 105 130 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','4. Select type of index:')

uicontrol(H.fig,'style','text',...
    'position',[520 105 150 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','5. Push to find a projection:')

uicontrol(H.fig,'style','text',...
    'position',[20 50 150 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','6. Visually explore the data:')

uicontrol(H.fig,'style','text',...
    'position',[200 50 220 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','7. Output the following:')

uicontrol(H.fig,'style','text',...
    'position',[400 50 200 20],...
    'fontsize',9,...
    'horizontalalignment','left',...
    'string','8. Find another projection:')


%%%%%%% BUTTONS  %%%%%%%%%%%%%%%%%%%%   
uicontrol(H.fig,'style','pushbutton',...
    'position',[14 491 88 23],...
    'string','LOAD DATA',...
    'tooltipstring','This will bring up the Load Data GUI',...
    'callback','loadgui')

uicontrol(H.fig,'style','pushbutton',...
    'position',[14 463 88 23],...
    'string','TRANSFORM',...
    'tooltipstring','This will bring up the Transform Data GUI.',...
    'callback','transformgui')

%%%%%%%%%%%%%%%%%%

uicontrol(H.fig,'style','pushbutton',...
    'position',[550 80 80 25],...
    'string','START',...
    'tooltipstring','This will start the search.',...
    'callback','ppedagui(''startppeda'')')

uicontrol(H.fig,'style','pushbutton',...
    'position',[180 22 80 25],...
    'string','PROJECTION',...
    'tooltipstring','This will save the projection matrix to the workspace.',...
    'callback','ppedagui(''projout'')')

uicontrol(H.fig,'style','pushbutton',...
    'position',[270 22 80 25],...
    'string','DATA',...
    'tooltipstring','This will save the projected data to the workspace.',...
    'callback','ppedagui(''dataout'')')

uicontrol(H.fig,'style','pushbutton',...
    'position',[30 22 100 25],...
    'string','GRAPHICAL EDA',...
    'tooltipstring','This will bring up the Graphical EDA GUI.',...
    'callback','ppedagui(''grapheda'')')

uicontrol(H.fig,'style','pushbutton',...
    'position',[400 22 175 25],...
    'string','FIND ANOTHER STRUCTURE',...
    'tooltipstring','This will remove the structure and find another interesting projection.',...
    'callback','ppedagui(''anothstruct'')')

% Close button
uicontrol(H.fig,'style','pushbutton',...
    'position',[620 485 66 25],...
    'string','CLOSE',...
    'callback','ppedagui(''close'')',...
    'tooltipstring','Push this button to close the GUI window.')


%%%%%%      EDIT BOXES  %%%%%%%%%%%%%%%%%%%%%%
% First frame
H.step = uicontrol('style','edit',...
    'string','10',...
    'position',[30 80 50 22],...
    'backgroundcolor','white');

H.trials = uicontrol('style','edit',...
    'string','4',...
    'position',[140 80 50 22],...
    'backgroundcolor','white',...
    'tooltipstring','Number of trials for a given starting configuration.');

H.nohits = uicontrol('style','edit',...
    'string','5',...
    'position', [265 80 82 22] ,...
    'backgroundcolor','white',...
    'tooltipstring','Number of searches with no improvement before neighborhood is made smaller.');



%%%%%%%%% POPUPMENU %%%%%%%%%%%%%%%%%

H.index = uicontrol('style','popupmenu',...
    'position',[405 80 82 22],...
    'backgroundcolor','white',...
    'String',{'Chi-square','Moment'});

% Save Handles for THIS GUI in the UserData for this figure.
set(gcf,'userdata',H)
