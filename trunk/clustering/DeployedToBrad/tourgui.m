function tourgui(arg)
% TOURGUI Data Tours Gui
%
% This GUI function allows one to conduct tours of the data to seek out new
% structure and new patterns... to boldly go where no analyst has gone
% before.
%
% It includes the grand tour, the pseudo grand tour, and the permutation
% tour. 
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       tourgui
%
%   NOTE: Group colors on this GUI refer to group labels, if loaded.
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','tourgui');
if isempty(flg)
    % then create the gui
    tourslayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'grandtour')
    % Display all possible pairwise scatterplots with polar smooths.
    grandtour
elseif strcmp(arg,'pseudotour')
    % Display all possible pairwise bivariate histograms.
    pseudotour
elseif strcmp(arg,'permtour')
    % Display scatterplots with hexagonal smoothing.
    permtour
elseif strcmp(arg,'gtdataout')
    % Export projected torus grand tour data to the workspace.
    % First get the data and project.
    ud = get(0,'userdata');
    if ~isempty(ud.gt)
        data = ud.X*ud.gt;
    else
        errordlg('You have not gone on a tour yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Grand Tour Projected Data to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)
elseif strcmp(arg,'gtprojout')
    % Export projection matrix from the grand tour to the workspace.
    ud = get(0,'userdata');
    if ~isempty(ud.gt)
        data = ud.gt;
    else
        errordlg('You have not gone on a tour yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Grand Tour Projection to Workspace';
    def = {'projection'};
    saveinfo(promptstrg,titlestrg,def,data)
elseif strcmp(arg,'ptdataout')
    % Export projected pseudo tour data to the workspace.
    ud = get(0,'userdata');
    if ~isempty(ud.pgt)
        data = ud.X*ud.pgt;
    else
        errordlg('You have not gone on a tour yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Pseudo Grand Tour Projected Data to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)
elseif strcmp(arg,'ptprojout')
    % Export projection matrix from pseudo tour to the workspace.
    ud = get(0,'userdata');
    if ~isempty(ud.pgt)
        data = ud.pgt;
    else
        errordlg('You have not gone on a tour yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Pseudo Grand Tour Projection to Workspace';
    def = {'projection'};
    saveinfo(promptstrg,titlestrg,def,data)
elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','tourgui');
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

%************************************************************
%************************************************************
function grandtour
  
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
Hf = findobj('tag','gt');
if isempty(Hf)
    % then create the new thing
    tg = findobj('tag','tourgui');
    H = get(tg,'userdata');
        % Get the various stuff from the GUI
    gtstep = str2double(get(H.gtstep,'string'));
    if gtstep <= 0 
        errordlg('The step size must be greater than 1.')
        return
    end
    gtdim = round(str2double(get(H.gtdim,'string')));
    if gtdim <= 1 
        errordlg('The number of dimensions must be greater than 2.')
        return
    elseif gtdim > p
        errordlg('The number of dimensions must be in the interval 2 to p.')
        return
    end
    gtiter = round(str2double(get(H.gtiter,'string')));
    if gtiter <= 1
        errordlg('The number of iterations must be greater than 1.')
        return
    end
    hf = figure;
    set(hf,'tag','gt','numbertitle','off','name','EDA: Torus Grand Tour')
    % Upon figure close, this should delete from the array.
    set(hf,'CloseRequestFcn',...
        'tg = findobj(''tag'',''tourgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
    H.plots = [H.plots, hf];
    set(tg,'userdata',H)
    gtdisp = get(H.gtdisplay,'value');
    % 1. Scatterplot -> torustour
    % 2. Andrews -> kdimtour with 'a' as type
    % 3. Parallel -> kdimtour with 'p' as type
    switch gtdisp
        case 1
            % run torustour
            if gtdim > 2
                errordlg('You can only do a scatterplot in 2 dimensions.')
                close(hf)
                return
            end
            runtorustour(ud.X,gtiter,hf,gtstep)
        case 2
            % runkdimtour with type 'a'
            runkdimtour(ud.X,gtiter,gtdim,'a',hf,gtstep)
 
        case 3
            % runkdimtour with type 'p'
            runkdimtour(ud.X,gtiter,gtdim,'p',hf,gtstep)
    end
else
    gtud = get(Hf,'userdata');
    switch gtud.gtdisp   % save this in the structure
        case 1
            % run torustour
            runtorustour(ud.X,gtud.maxit,Hf,gtud.delt)
        case 2
            % run andrews kdimtour
            runkdimtour(ud.X,gtud.maxit,gtud.k,'a',Hf,gtud.delt)
        case 3
            % run parallel kdimtour
            runkdimtour(ud.X,gtud.maxit,gtud.k,'p',Hf,gtud.delt)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pseudotour
  
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end

% Check to see if tour window exists
Hf = findobj('tag','pgt');
if isempty(Hf)
    % then create the new thing.
    tg = findobj('tag','tourgui');
    H = get(tg,'userdata');
    % Get the values from the GUI.
    pstep = str2double(get(H.psstep,'string'));
    if pstep <= 0
        errordlg('The step size must be greater than 0.')
        return
    end
    psiter = str2double(get(H.psiter,'string'));
    if psiter <= 1
        errordlg('The maximum number of iterations must be greater than 1.')
        return
    end
    hf = figure;
    set(hf,'tag','pgt','numbertitle','off','name','EDA: Pseudo Grand Tour')
    % Upon figure close, this should delete from the array.
    set(hf,'CloseRequestFcn',...
        'tg = findobj(''tag'',''tourgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
    H.plots = [H.plots, hf];
    set(tg,'userdata',H)
    runptour(ud.X,psiter,hf,pstep);
else
    gtud = get(Hf,'userdata');
    runptour(ud.X,gtud.maxit,gtud.Hf,gtud.delt)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function permtour
  
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
tg = findobj('tag','tourgui');
H = get(tg,'userdata');
hf = figure;
% MIGHT NEED TWO DIFFERENT ONES HERE - ANDREWS AND PARALLEL
set(hf,'numbertitle','off','name','EDA: Permutation Tour')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'tg = findobj(''tag'',''tourgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)
% Get the desired type of tour - all permutations or Wegman's minimal tour
tourtype = get(H.permtype,'value');
% Get the desried type of display - Andrews or parallel
disptype = get(H.permdisplay,'value');
% Get the information to plot in colors or not.
colflag = get(H.permcolflag,'value');
if isempty(ud.classlab) & colflag == 1
    % The user chose to display using colors and class labels are not
    % loaded.
    close(hf)
    errordlg('You must have some group/class labels loaded to use color by groups.')
    return
end

% Now do the tour.
if tourtype == 1 & disptype == 1
    % Then do permutation tour with all permutations
    permtourandrews(ud.X,0,colflag,hf)
elseif tourtype == 2 & disptype == 1
    % Then do permutation tour with Wegman's partial tour
    permtourandrews(ud.X,1,colflag,hf)
elseif tourtype == 1 & disptype == 2
    % Then do paralle coordinate tour with all permutations
    % Actually, this one is not available for parallel coordinates.
    % Only need to do the wegman partial tour, so provide an error.
    close(hf)
    errordlg('You can only do the minimal version with the permutation tour in parallel coordinates.')
    return
elseif tourtype == 2 & disptype == 2
    % Then do parallel coordinate tour with Wegman's partial tour
    permtourparallel(ud.X,colflag,hf)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function permtourparallel(X,colflag,Hfig)
%   PERMTOURPARALLEL Permutes axes in parallel coordinates
% SPecial version for the tourgui.


[n,p] = size(X);
% Get the permutations - each row corresponds to a different one.
P = permweg(p);
[nP,pP] = size(P);
set(Hfig,'tag','figparatour','renderer','painters','DoubleBuffer','on','backingstore','off');
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
title('Hit any key to step through the tour:')

% Loop through all of the permutations.
for i = 1:nP
    % permute the columns by the row of the permutation matrix
    xP = X(:,P(i,:));
    parallel(Hline,xP,Htext,P(i,:),colflag);
    pause
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parallel(Hline,x,Htext,P,colflag)
if colflag == 1
    % Then plot using colors based on ud.classlab
    ud = get(0,'userdata');
end
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
    P = fliplr(P);
    for i = 1:p            
        set(Htext(i),'string', ['x' num2str(P(i))]);
    end
elseif colflag == 1
    % then display WITH group colors.
    % Can only display up to 7 groups by color. this should be sufficient.
    % We will use the default MATLAB colors
    cols = {'b';'g';'r';'c';'m';'y';'k'};
    clab = unique(ud.classlab);
    if length(clab) > length(cols)
        errordlg('The maximum number of allowed groups is 7.')
        return
    end
    for k = 1:length(clab)
        % loop over all of the different colors and display
        inds = find(ud.classlab==clab(k));
        for i=inds
            set(Hline(i),'xdata',xn(i,:),'ydata',fliplr(ypos),'color',cols{k})
        end   
        P = fliplr(P);
        for i = 1:p            
            set(Htext(i),'string', ['x' num2str(P(i))]);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function permtourandrews(X,typeflag,colflag,Hfig)
%   PERMTOURANDREWS Permutes variable order in Andrews' curves
% SPecial version for the tourgui.

[n,p] = size(X);
if typeflag == 1
    % Get the Wegman partial tour
    % Get the permutations - each row corresponds to a different one.
    P = permweg(p);
else
    P = perms(1:p);
end
[nP,pP] = size(P);
set(Hfig,'tag','figparatour','renderer','painters','DoubleBuffer','on','backingstore','off');
% THe following gets the axis lines.
% Save the text handles, so they can be permuted, too.
% Save the text strings, too.
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

title('Hit any key to step through the tour:')

% Loop through all of the permutations.
for i = 1:nP
    % permute the columns by the row of the permutation matrix
    xP = X(:,P(i,:));
    andrews(Hline,xP,theta,ang,colflag);
    pause
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       ANDREWS CURVES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function andrews(Hline,data,theta,ang,colflag)
[n,p] = size(data);
if colflag == 1
    % Then plot using colors based on ud.classlab
    ud = get(0,'userdata');
end
% Now generate a y for each observation
%
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
    clab = unique(ud.classlab);
    if length(clab) > length(cols)
        errordlg('The maximum number of allowed groups is 7.')
        return
    end
    for k = 1:length(clab)
        % loop over all of the different colors and display
        inds = find(ud.classlab==clab(k));
        for i=inds
            set(Hline(i),'xdata',theta,'ydata',y(i,:),'color',cols{k});
        end  
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P = permweg(p)
% This gets a smaller number of permutations to get all possible ones.

N = ceil((p-1)/2);
% Get the first sequence.
P(1) = 1;
for k = 1:(p-1)
    tmp(k) = (P(k) + (-1)^(k+1)*k);
    P(k+1) = mod(tmp(k),p);
end
% To match our definition of 'mod':
P(find(P==0)) = p;

for j = 1:N;
    P(j+1,:) = mod(P(j,:)+1,p);
    ind = find(P(j+1,:)==0);
    P(j+1,ind) = p;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function runptour(x,maxit,Hf,delt)

% PSEUDOTOUR    Pseudo Grand Tour
% special version for the GUI.

gtud = get(Hf,'userdata');      % here we will store the iteration and the step

% Now do the tour stuff
[n,p] = size(x);
if rem(p,2) ~= 0
    % Add zeros to the end.
    x = [x,zeros(n,1)];
    p = p+1;
end
% Set up vector of frequencies.
th = mod(exp(1:p),1);
% This is a small irrational number:
% delt = exp(1)^(-5); 
cof = sqrt(2/p);
% Set up storage space for projection vectors.
a = zeros(p,1);
b = zeros(p,1);
z = zeros(n,2);

if isempty(gtud)
    % then get the initial plot stuff.
    % Get an initial plot, so the tour can be implemented 
    % using Handle Graphics.
    gtud.ph = plot(z(:,1),z(:,2),'o','erasemode','normal');
    gtud.maxit = maxit;
    gtud.Hf = Hf;
    gtud.delt = delt;
    gtud.iter = 1;
    gtud.t = 0;
    axis equal, axis off
    set(Hf,'backingstore','off','renderer','painters','DoubleBuffer','on')
    gtud.H = uicontrol(gcf,'style','text',...
        'units','normalized',...
        'position',[0.01 0.01 0.2 0.05],...
        'horizontalalignment','left',...
        'string','Iteration: ');
    Hbuttstop = uicontrol(Hf,'style','pushbutton',...
        'units','normalized',...
        'position',[0.9 0.01, 0.1 0.05],...
        'string','Stop Tour',...
        'createfcn','ud=get(0,''userdata'');ud.pgtstop=0;set(0,''userdata'',ud)',...
        'deletefcn','ud=get(0,''userdata'');ud.pgtstop=1;set(0,''userdata'',ud)',...
        'callback','ud=get(0,''userdata'');ud.pgtstop=1;set(0,''userdata'',ud)');
    Hbuttstart = uicontrol(Hf,'style','pushbutton',...
        'units','normalized',...
        'position',[0.65 0.01, 0.15 0.05],...
        'string','Continue Tour',...
        'callback',['ud=get(0,''userdata'');',...
            'ud.pgtstop=0;set(0,''userdata'',ud);',...
            'tourgui(''pseudotour'')']);
    set(Hf,'userdata',gtud)
end
pause(0.01)
% When user pushes stop button, stoptour is reset to true - stop the tour
% when user pushes the restart, stoptour is reset to false - run the tour

iter = gtud.iter;
t = gtud.t;
while iter <= maxit
    t = t + delt;
    gtud.t = t;
    ud = get(0,'userdata');
    if ud.pgtstop == 0
        % tour is not stopped
        % Find the transformation vectors.
        for j=1:p/2
            a(2*(j-1)+1)=cof*sin(th(j)*t);
            a(2*j)=cof*cos(th(j)*t);
            b(2*(j-1)+1)=cof*cos(th(j)*t);
            b(2*j)=cof*(-sin(th(j)*t));
        end
        % Project onto the vectors.
        z(:,1)=x*a;
        z(:,2)=x*b;
        set(gtud.ph,'xdata',z(:,1),'ydata',z(:,2))
        set(gtud.H,'string',['Iteration: ',int2str(iter)])
        drawnow
    else
        % give the user a chance to bring up the tourgui and save data
        % or they just might want to look at it. 
        ud.pgt = [a(:), b(:)];
        set(0,'userdata',ud)
        break
    end
    iter = iter + 1;
    gtud.iter=iter;
    set(Hf,'userdata',gtud)
end


function runtorustour(x,maxit,Hf,delt)

% TORUSTOUR    Grand Tour - Torus Winding Algorithm
% Special version for the GUI

gtud = get(Hf,'userdata');  % here we store the iteration and the step
[n,p] = size(x);
% Set up vector of frequencies.
N = 2*p - 3;
lam = mod(exp(1:N),1);
% This is a small irrational number:
% delt = exp(1)^(-5); 
% Get the indices to build the rotations.
J = 2:p;
I = ones(1,length(J));
I = [I, 2*ones(1,length(J)-1)];
J = [J, 3:p];
E = eye(p,2);   % Basis vectors
if isempty(gtud)
    % Get an initial plot.
    z = zeros(n,2);
    gtud.ph = plot(z(:,1),z(:,2),'o','erasemode','normal');
    axis equal, axis off
    set(Hf,'backingstore','off','renderer','painters','DoubleBuffer','on')
    gtud.maxit = maxit;
    gtud.Hf = Hf;
    gtud.delt = delt;
    gtud.k = 1;     % this is the iteration index
    gtud.gtdisp = 1;    % since this is a scatterplot tour
    gtud.H = uicontrol(gcf,'style','text',...
        'units','normalized',...
        'position',[0.01 0.01 0.2 0.05],...
        'horizontalalignment','left',...
        'string','Iteration: ');
    Hbuttstop = uicontrol(Hf,'style','pushbutton',...
        'units','normalized',...
        'position',[0.9 0.01, 0.1 0.05],...
        'string','Stop Tour',...
        'createfcn','ud=get(0,''userdata'');ud.gtstop=0;set(0,''userdata'',ud)',...
        'deletefcn','ud=get(0,''userdata'');ud.gtstop=1;set(0,''userdata'',ud)',...
        'callback','ud=get(0,''userdata'');ud.gtstop=1;set(0,''userdata'',ud)');
    Hbuttstart = uicontrol(Hf,'style','pushbutton',...
        'units','normalized',...
        'position',[0.65 0.01, 0.15 0.05],...
        'string','Resume Tour',...
        'callback',['ud=get(0,''userdata'');',...
            'ud.gtstop=0;set(0,''userdata'',ud);',...
            'tourgui(''grandtour'')']);
    set(Hf,'userdata',gtud)
    drawnow
end
pause(0.01)
k = gtud.k;
% Start the tour.
while k <= maxit
    ud = get(0,'userdata');
    if ud.gtstop == 0
        % tour is not stopped
        % Find the rotation matrix.
        Q = eye(p);
        for j = 1:N
            dum = eye(p);
            dum([I(j),J(j)],[I(j),J(j)]) = cos(lam(j)*k*delt);
            dum(I(j),J(j)) = -sin(lam(j)*k*delt);
            dum(J(j),I(j)) = sin(lam(j)*k*delt);
            Q = Q*dum;
        end
        % Rotate basis vectors.
        A = Q*E;
        % Project onto the new basis vectors.
        z = x*A;
        set(gtud.ph,'xdata',z(:,1),'ydata',z(:,2))
        set(gtud.H,'string',['Iteration: ',int2str(k)])
        drawnow
    else
        % give the user a chance to bring up the tourgui and save data
        % of they just might want to look at it.
        ud.gt = A;
        set(0,'userdata',ud)
        break
    end
    k = k + 1;
    gtud.k = k;
    set(Hf,'userdata',gtud)
end

function runkdimtour(x,maxit,k,typ,Hf,delt)

% KDIMTOUR    Grand Tour in k Dimensions - Torus Winding Algorithm
%
% special version for GUI
%   'a' produces Andrews' curves
%   'p' produces parallel coordinate plots (default)

gtud = get(Hf,'userdata');  % here we store the iteration and the step
[n,p] = size(x);
% Set up vector of frequencies.
N = 2*p - 3;
lam = mod(exp(1:N),1);
% % This is a small irrational number:
% delt = exp(1)^(-3); 
% Get the indices to build the rotations.
J = 2:p;
I = ones(1,length(J));
I = [I, 2*ones(1,length(J)-1)];
J = [J, 3:p];
E = eye(p,k);   % Basis vectors

if isempty(gtud)
    % Get an initial plot.
%     z = zeros(n,2);
%     gtud.ph = plot(z(:,1),z(:,2),'o','erasemode','normal');
    set(Hf,'backingstore','off','renderer','painters','DoubleBuffer','on')

    gtud.maxit = maxit;
    gtud.Hf = Hf;
    gtud.delt = delt;
    gtud.k = k;     % this is the number of display dimensions
    gtud.K = 1;     % This is the current iteration index
    gtud.maxit = maxit;
    if strcmp(typ,'p')
        gtud.typ = 'p';
        gtud.gtdisp = 3;    % since this is a parallel coordinates tour
        % get the axes lines
        kk = k;
        ypos = linspace(0,1,kk);
        xpos = [0 1];
        for i=1:kk            
            line(xpos,[ypos(i) ypos(i)],'color','k')
            text(-0.05,ypos(i), ['x' num2str(kk)] )
            kk=kk-1;
        end
        axis off
        gtud.hax = gca;
    else
        gtud.typ = 'a';
        gtud.gtdisp = 2;    % since this is a Andrews curves tour
        gtud.hax = axes('position',[0.05 0.075 0.9  0.8]);
        %     set(gtud.hax,'visible','off')
        set(gtud.hax,'xlimmode','manual')
        set(gtud.hax,'xlim',[-pi pi])
        axis off
    end
    gtud.H = uicontrol(gcf,'style','text',...
        'units','normalized',...
        'position',[0.01 0.01 0.2 0.05],...
        'horizontalalignment','left',...
        'string','Iteration: ');
    Hbuttstop = uicontrol(Hf,'style','pushbutton',...
        'units','normalized',...
        'position',[0.9 0.01, 0.1 0.05],...
        'string','Stop Tour',...
        'createfcn','ud=get(0,''userdata'');ud.gtstop=0;set(0,''userdata'',ud)',...
        'deletefcn','ud=get(0,''userdata'');ud.gtstop=1;set(0,''userdata'',ud)',...
        'callback','ud=get(0,''userdata'');ud.gtstop=1;set(0,''userdata'',ud)');
    Hbuttstart = uicontrol(Hf,'style','pushbutton',...
        'units','normalized',...
        'position',[0.65 0.01, 0.15 0.05],...
        'string','Resume Tour',...
        'callback',['ud=get(0,''userdata'');',...
            'ud.gtstop=0;set(0,''userdata'',ud);',...
            'tourgui(''grandtour'')']);
    % Set up the line handles - need n of these
    gtud.Hline = zeros(1,n);
    for i = 1:n
        gtud.Hline(i) = line('xdata',nan,'ydata',nan,'linestyle','-');
    end
    set(Hf,'userdata',gtud)
    drawnow
end
pause(0.01)
% Start the tour.
if strcmp(gtud.typ,'p')
    K = gtud.K;
    while K <= maxit
        ud = get(0,'userdata');
        if ud.gtstop == 0
            % tour is not stopped
            % Find the rotation matrix.
            Q = eye(p);
            for j = 1:N
                dum = eye(p);
                dum([I(j),J(j)],[I(j),J(j)]) = cos(lam(j)*K*delt);
                dum(I(j),J(j)) = -sin(lam(j)*K*delt);
                dum(J(j),I(j)) = sin(lam(j)*K*delt);
                Q = Q*dum;
            end
            % Rotate basis vectors.
            A = Q*E;
            % Project onto the new basis vectors.
            z = x*A;    
            parallelkd(gtud.Hline,z);
            set(gtud.H,'string',['Iteration: ',int2str(K)])
            drawnow
        else
            % give the user a chance to bring up the tourgui and save data
            % or look at it
            ud.gt = A;
            set(0,'userdata',ud)
            break
        end
        K = K + 1;
        gtud.K = K;
        set(Hf,'userdata',gtud)
    end   % while loop
else
    kk = k;    % number of desired dimensions
    theta = -pi:0.1:pi;    %this defines the domain that will be plotted
    y = zeros(n,kk);       %there will n curves plotted, one for each obs
    ang = zeros(length(theta),kk);   %each row must be dotted w/ observation
    % Get the string to evaluate function.
    fstr = ['[1/sqrt(2) '];   %Initialize the string.
    for i = 2:kk
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
    K = gtud.K;
    while K <= maxit
        ud = get(0,'userdata');
        if ud.gtstop == 0
            % Find the rotation matrix.
            Q = eye(p);
            for j = 1:N
                dum = eye(p);
                dum([I(j),J(j)],[I(j),J(j)]) = cos(lam(j)*K*delt);
                dum(I(j),J(j)) = -sin(lam(j)*K*delt);
                dum(J(j),I(j)) = sin(lam(j)*K*delt);
                Q = Q*dum;
            end
            % Rotate basis vectors.
            A = Q*E;
            % Project onto the new basis vectors.
            z = x*A;    
            axis off
            andrewskd(gtud.Hline,z,theta,ang);
            set(gtud.H,'string',['Iteration: ',int2str(K)])
            drawnow
        else
            % give the user a chance to bring up the tourgui and save data
            % or look at it
            ud.gt = A;
            set(0,'userdata',ud)
            break
        end   % if-else loop
        K = K + 1;
        gtud.K = K;
        set(Hf,'userdata',gtud)
    end % while loop
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       ANDREWS CURVES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function andrewskd(Hline,data,theta,ang)
[n,p] = size(data);
% keyboard
% Now generate a y for each observation
%
for i=1:n     %loop over each observation
  for j=1:length(theta)
    y(i,j)=data(i,:)*ang(j,:)'; 
  end
end

for i=1:n
  set(Hline(i),'xdata',theta,'ydata',y(i,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parallelkd(Hline,x)

% If parallel coordinates, then change range.
% map all values onto the interval 0 to 1
% lines will extend over the range 0 to 1
md = min(x(:)); % find the min of all the data
rng = range(x(:));  %find the range of the data
xn = (x-md)/rng;
[n,p] = size(x);
ypos = linspace(0,1,p);
for i=1:n
    %     line(x(i,:),fliplr(ypos),'color','k')
    set(Hline(i),'xdata',xn(i,:),'ydata',fliplr(ypos))
end    


