function bivgui(arg)
% BIVGUI  Distribution Shapes - Bivariate GUI
%
% This GUI function allows one to explore the bivariate distributions in
% the data set. These are the distributions of pairs of columns of the data
% matrix X.
%
% This GUI provides the means to create bivariate polar smooths in
% scatterplots, hexagonal binning in scatterplots and bivariate histograms.
%
% This can be called from the edagui main GUI or as a stand-alone function
% from the command line. To call from the command line, use
%
%       bivgui
%
% NOTE: Coloring by groups does not affect the plots in this GUI.
%
%   Exploratory Data Analysis Toolbox, December 2006
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','bivgui');
if isempty(flg)
    % then create the gui
    dsblayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'polarplot')
    % Display all possible pairwise scatterplots with polar smooths.
    disppolar
elseif strcmp(arg,'disphist')
    % Display all possible pairwise bivariate histograms.
    disphist
elseif strcmp(arg,'hexplot')
    % Display scatterplots with hexagonal smoothing.
    disphex
elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','bivgui');
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

%%%%%%%%%%%%%%%%%%%%%%%%%  SUB FUNCTIONs %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function disppolar    
% This function displays all possible pairwise scatterplots.
% Adds polar smoothing.
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
tg = findobj('tag','bivgui');
H = get(tg,'userdata');
% Get the value of the radio button indicating robust loess or not.
rflag = get(H.robflag,'value');
% Get the value of the smoothing parameter
lam = str2double(get(H.smooth,'string'));
if ~(lam > 0 & lam < 1)
    errordlg('Smoothing parameter must be between 0 and 1.','Data Entry Error')
    return
end
% Get the degree of the polynomial
deg = str2double(get(H.degree,'string'));
if deg ~= 1 & deg ~= 2
    errordlg('Degree of polynomial must be 1 (linear) or 2 (quadratic).')
    return
end
% Get the dimensions to plot.
dims = get(H.dimpol,'string');
try
    if strcmp('all',dims)
        % Wants to plot all dimensions
        dim = 1:p;
    else
        % Wants just a subset - convert to numbers.
        eval(['dim = [' dims '];'])
    end
catch
    errordlg('Data entry error in edit box.','Data Enty Error')
    return
end
if length(dims) == 1
    errordlg('Must have more than 1 dimension specified in edit box.','Data Entry Error')
    return
end
hf = figure;
set(hf,'numbertitle','off','name','EDA: Pairwise Scatterplots with Polar Smooths')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'tg = findobj(''tag'',''bivgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)
plotpolar(ud.X(:,dim),lam,deg,rflag,dim)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function disphist
% This function displays the histograms.
  
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
tg = findobj('tag','bivgui');
H = get(tg,'userdata');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% This whole section was changed on August 19. The bandwidths do not work
% correctly and it is difficult for data enty. So, change to allow the user
% to enter the number of bins instead.
% % Get the bandwidths
% bs = get(H.band,'string');
% if strcmp(bs,'Default')
%     % Use the default bandwidths
%     bw = 3.5*std(ud.X)*n^(-1/(p+1));
%     bws = num2str(bw,2);
%     set(H.band,'string',bws)
% else
%     % Get what the user enetered.
%     eval(['bw = [' bs '];'])
% end
% % Get the dimensions to plot.
% dims = get(H.dimhist,'string');
% try
%     if strcmp('all',lower(dims))
%         % Wants to plot all dimensions
%         dim = 1:p;
%     else
%         % Wants just a subset - convert to numbers.
%         eval(['dim = [' dims '];'])
%     end
% catch
%     errordlg('Data entry error in edit box.','Data Enty Error')
%     return
% end
% if length(dim) == 1
%     errordlg('Must have more than 1 dimension specified in edit box.','Data Entry Error')
%     return
% end
% if length(bw) ~= length(dim)
%     errordlg('You must enter one bandwidth per dimension.','Date Entry Error')
%     return
% end
% % check the number of bins. If too small, then the user should enter
% % the h values. Provide an error.
%  % This is just a check.
% rng = max(ud.X(dims)) - min(ud.X(dims));
% nb = rng./bw;
% if any(nb < 4)
%     errordlg('Some of the bandwidths are too large, yielding too few bins. Make them smaller.')
%     return
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the number of bins
% Default number of bins is 10.
nb = round(str2double(get(H.band,'string')));
% Get the dimensions to plot.
dims = get(H.dimhist,'string');
try
    if strcmp('all',lower(dims))
        % Wants to plot all dimensions
        dim = 1:p;
    else
        % Wants just a subset - convert to numbers.
        eval(['dim = [' dims '];'])
    end
catch
    errordlg('Data entry error in edit box.','Data Enty Error')
    return
end
if length(dim) == 1
    errordlg('Must have more than 1 dimension specified in edit box.','Data Entry Error')
    return
end

% check the number of bins. 
if nb < 5
    errordlg('Should have 5 or more bins.')
    return
end

rng = max(ud.X(:,dim)) - min(ud.X(:,dim));
bw = rng/nb;



hf = figure;
set(hf,'numbertitle','off','name','EDA: Pairwise Bivariate Histograms')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'tg = findobj(''tag'',''bivgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)
plothist(ud.X(:,dim),bw,dim)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function disphex
% This function displays the histograms.
  
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
tg = findobj('tag','bivgui');
H = get(tg,'userdata');
% Get the bandwidths
Nb = round(str2double(get(H.bins,'string')));
% Get the dimensions to plot.
dims = get(H.dimhex,'string');
try
    if strcmp('all',lower(dims))
        % Wants to plot all dimensions
        dim = 1:p;
    else
        % Wants just a subset - convert to numbers.
        eval(['dim = [' dims '];'])
    end
catch
    errordlg('Data entry error in edit box.','Data Enty Error')
    return
end
if length(dim) == 1
    errordlg('Must have more than 1 dimension specified in edit box.','Data Entry Error')
    return
end


hf = figure;
set(hf,'numbertitle','off','name','EDA: Pairwise Scatterplots with Hexagonal Binning')
% Upon figure close, this should delete from the array.
set(hf,'CloseRequestFcn',...
    'tg = findobj(''tag'',''bivgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
H.plots = [H.plots, hf];
set(tg,'userdata',H)
plothex(ud.X(:,dim),Nb,dim)


%%%%%%%%%%%%%%%%%%%%   HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%

function plothex(X,Nb,dim)
% does the scatterplot matrix, but adds polar smooths.
% lam is the smoothing parameter, deg is the degree of the polynomial and
% rflag is 1 means to use robust loess, and a 0 means to use regular.
ud = get(0,'userdata'); % for variable names

Hfig = findobj('name','EDA: Pairwise Scatterplots with Hexagonal Binning');
set(Hfig, 'units','normalized',...
    'position',  [0 0.0365 0.9678 0.8750],...
    'toolbar','none',...
    'menubar','none');
[n,p] = size(X);
% Order of axes is left-right, top-bottom
pp = 0;
I = 0; J = 0;
for j = (p-1):-1:0
    I = I + 1;
    for i = 0:(p-1)
        J = J + 1;
        box on
        pp = pp + 1;
        subplot(p,p,pp)
        if I~=J
            % The following is the column index (to data) for the X and Y
            % variables.
            set(gca,'yticklabel','','xticklabel','','ticklength',[0 0])
            % Do the bivariate histogram.
            Xt = [X(:,J),X(:,I)];
            hexplot(Xt,Nb)
            drawnow
        else
            axis off
            % This is a center axes - plot the variable name.
            if isnumeric(ud.varlab)
                text(0.35,0.45, num2str(ud.varlab(dim(I))))
            elseif iscell(ud.varlab)
                text(0.35,0.45,ud.varlab{dim(I)})
            end
        end  % if stmt
    end   % for j loop
    J = 0;
end   % for i loop


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

function plothist(X,bw,dim)
% does the scatterplot matrix, but adds polar smooths.
% lam is the smoothing parameter, deg is the degree of the polynomial and
% rflag is 1 means to use robust loess, and a 0 means to use regular.
ud = get(0,'userdata'); % for variable names

Hfig = findobj('name','EDA: Pairwise Bivariate Histograms');
set(Hfig, 'units','normalized',...
    'position',  [0 0.0365 0.9678 0.8750],...
    'toolbar','none',...
    'menubar','none');
[n,p] = size(X);
% Order of axes is left-right, top-bottom
pp = 0;
I = 0; J = 0;
for j = (p-1):-1:0
    I = I + 1;
    for i = 0:(p-1)
        J = J + 1;
        box on
        pp = pp + 1;
        subplot(p,p,pp)
        if I~=J
            % The following is the column index (to data) for the X and Y
            % variables.
            set(gca,'yticklabel','','xticklabel','','ticklength',[0 0])
            % Do the bivariate histogram.
            Xt = [X(:,J),X(:,I)];
            Z = cshist2d(Xt,1,[bw(J),bw(I)]);
            box off
          
            drawnow
        else
            axis off
            % This is a center axes - plot the variable name.
            if isnumeric(ud.varlab)
                text(0.35,0.45, num2str(ud.varlab(dim(I))))
            elseif iscell(ud.varlab)
                text(0.35,0.45,ud.varlab{dim(I)})
            end
        end  % if stmt
    end   % for j loop
    J = 0;
end   % for i loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  plotpolar(X,lam,deg,rflag,dim)
% does the scatterplot matrix, but adds polar smooths.
% lam is the smoothing parameter, deg is the degree of the polynomial and
% rflag is 1 means to use robust loess, and a 0 means to use regular.
ud = get(0,'userdata'); % for variable names

Hfig = findobj('name','EDA: Pairwise Scatterplots with Polar Smooths');
set(Hfig, 'units','normalized',...
    'position',  [0 0.0365 0.9678 0.8750],...
    'toolbar','none',...
    'menubar','none');
[n,p] = size(X);
minx = min(X);
maxx = max(X);
rngx = range(X);
% set up the axes
H.IndX = zeros(p,p);    % X dim for data
H.IndY = zeros(p,p);    % Y dim for data
H.AxesLims = cell(p,p); % Axes limits.
H.Haxes = zeros(p,p);   % Axes handles.
H.HlineReg = zeros(p,p);    % Line handles to non-highlighted data.

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
            set(gca,'yticklabel','','xticklabel','','ticklength',[0 0])
            % Do the scatterplot.
            H.HlineReg(I,J) = line('xdata',X(:,J),'ydata',X(:,I),...
                'markersize',3,'marker','o','linestyle','none');
            % Do the polar smooth and add to plot.
            hold on
            [xhat2,yhat2] =  polarloess(X(:,J),X(:,I),lam,deg,rflag);
            plot(xhat2,yhat2)
            hold off
            drawnow
            ax = axis;
            axis([ax(1)-rngx(J)*.05 ax(2)*1.05 ax(3)-rngx(I)*.05 ax(4)*1.05])
            H.AxesLims{I,J} = axis;
            axis manual
        else
            set(gca,...
                'Yticklabel','','xticklabel','',...
                'ticklength',[0 0])
            % This is a center axes - plot the variable name.
            if isnumeric(ud.varlab)
                text(0.35,0.45, num2str(ud.varlab(dim(I))))
            elseif iscell(ud.varlab)
                text(0.35,0.45,ud.varlab{dim(I)})
            end
            text(0.05,0.05,num2str(minx(I)))
            text(0.9,0.9,num2str(maxx(I)))
            axis([0 1 0 1])
            H.AxesLims{I,J} = [0 1 0 1];
        end  % if stmt
    end   % for j loop
    J = 0;
end   % for i loop


        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
function [xhato,yhato] = polarloess(x,y,lam,deg,rflag)
% POLARLOESS   Polar loess smoothing

%   W. L. and A. R. Martinez, 3-04
%   EDA Toolbox
%   Reference is Cleveland and McGill, Many Faces of a Scatterplot.
%   JASA, 1984.
% Step 1.
% Normalize using the median absolute deviation.
% We will use the Matlab 'inline' functionality.
md = inline('median(abs(x - median(x)))');
xstar = (x - median(x))/md(x);
ystar = (y - median(y))/md(y);
% Step 2.
s = ystar + xstar;
d = ystar - xstar;
% Step 3. Normalize these values.
sstar = s/md(s);
dstar = d/md(d);
% Step 4. Convert to polar coordinates.
[th,m] = cart2pol(sstar,dstar);
% Step 5. Transform radius m.
z = m.^(2/3);
% Step 6. Smooth z given theta.
n = length(x);
J = ceil(n/2);
% Get the temporary data for loess.
tx = -2*pi + th((n-J+1):n);
% So we can get the values back, find this.
ntx = length(tx);  
tx = [tx; th];
tx = [tx; th(1:J)];
ty = z((n-J+1):n);
ty = [ty; z];
ty = [ty; z(1:J)];
if rflag == 0
    tyhat = loess(tx,ty,tx,lam,deg);
elseif rflag ==1
    tyhat = loessr(tx,ty,tx,lam,deg);
end
% Step 7. Transform the values back.
% Note that we only need the middle values.
tyhat(1:ntx) = [];
mhat = tyhat(1:n).^(3/2);
% Step 8. Convert back to Cartesian.
[shatstar,dhatstar] = pol2cart(th,mhat);
% Step 9. Transform to original scales.
shat = shatstar*md(s);
dhat = dhatstar*md(d);
xhat = ((shat-dhat)/2)*md(x) + median(x);
yhat = ((shat+dhat)/2)*md(y) + median(y);
% Step 10. Plot the smooth.
% We use the convex hull to make it easier
% for plotting.
K = convhull(xhat,yhat);
xhato = xhat(K);
yhato = yhat(K);



function yhat = loess(x,y,xo,alpha,deg)
% LOESS   Basic loess smoothing
%
%   YHAT = LOESS(X,Y,XO,ALPHA,DEG)
%
%   This function performs the basic loess smoothing for univariate data.
%   YHAT is the value of the smooth. X and Y are the observed data. XO
%   is the domain over which to evaluate the smooth YHAT. ALPHA is the 
%   smoothing parameter, and DEG is the degree of the local fit (1 or 2).
%


%   W. L. and A. R. Martinez, 2-04
%   EDA Toolbox


if deg ~= 1 & deg ~= 2
% 	error('Degree of local fit must be 1 or 2')
end
if alpha <= 0 | alpha >= 1
	error('Alpha must be between 0 and 1')
end
if length(x) ~= length(y)
	error('Input vectors do not have the same length.')
end

% get constants needed
n = length(x);
k = floor(alpha*n);

% set up the memory
yhat = zeros(size(xo));

% for each xo, find the k points that are closest
for i = 1:length(xo)
	dist = abs(xo(i) - x);
	[sdist,ind] = sort(dist);
	Nxo = x(ind(1:k));	% get the points in the neighborhood
	Nyo = y(ind(1:k));
	delxo = sdist(k);  %% Check this
	sdist((k+1):n) = [];
	u = sdist/delxo;
	w = (1 - u.^3).^3;
	p = wfit(Nxo,Nyo,w,deg);
	yhat(i) = polyval(p,xo(i));
end

function p = wfit(x,y,w,deg)
% This will perform the weighted least squares
n = length(x);
x = x(:);
y = y(:);
w = w(:);
% get matrices
W = spdiags(w,0,n,n);
A = vander(x);
A(:,1:length(x)-deg-1) = [];
V = A'*W*A;
Y = A'*W*y;
[Q,R] = qr(V,0); 
p = R\(Q'*Y); 
p = p';		% to fit MATLAB convention

function yhat = loessr(x,y,xo,alpha,deg)
% LOESSR  Robust loess smoothing.
%
%   YHAT = LOESSR(X,Y,XO,ALPHA,DEG)
%
%   This function performs the robust loess smoothing for univariate data.
%   YHAT is the value of the smooth. X and Y are the observed data. XO
%   is the domain over which to evaluate the smooth YHAT. ALPHA is the 
%   smoothing parameter, and DEG is the degree of the local fit (1 or 2).
%


%   W. L. and A. R. Martinez, 3-4-04


if deg ~= 1 & deg ~= 2
	error('Degree of local fit must be 1 or 2')
end
if alpha <= 0 | alpha >= 1
	error('Alpha must be between 0 and 1')
end
if length(x) ~= length(y)
	error('Input vectors do not have the same length.')
end

% get constants needed
n = length(x);
k = floor(alpha*n);
toler = 0.003;	% convergence tolerance for robust procedure
maxiter = 50;	% maximum allowed number of iterations

% set up the memory
yhat = zeros(size(xo));

% for each xo, find the k points that are closest
% First find the initial loess fit.
for i = 1:length(xo)
	dist = abs(xo(i) - x);
	[sdist,ind] = sort(dist);
	Nxo = x(ind(1:k));	% get the points in the neighborhood
	Nyo = y(ind(1:k));
	delxo = sdist(k);  %% Check this
	sdist((k+1):n) = [];
	u = sdist/delxo;
	w = (1 - u.^3).^3;
	p = wfit(Nxo,Nyo,w,deg);
	yhat(i) = polyval(p,xo(i));
	niter = 1;
	test = 1;
	ynew = yhat(i);	% get a temp variable for iterations
	while test > toler & niter <= maxiter
		% do the robust fitting procedure
        niter = niter + 1;
		yold = ynew;
		resid = Nyo - polyval(p,Nxo);	% calc residuals	
		s = median(abs(resid));
		u = min(abs(resid/(6*s)),1);	% scale so all are between 0 and 1
		r = (1-u.^2).^2;	
		nw = r.*w;
		p = wfit(Nxo,Nyo,nw,deg);	% get the fit with new weights
		ynew = polyval(p,xo(i));	% what is the value at x
		test = abs(ynew - yold);
	end
	% converged - set the value to ynew
	yhat(i) = ynew;
end


function hexplot(X,N,flag)

% HEXPLOT   Hexagonal Binning - Scatterplot
% 
%   HEXPLOT(X,N,FLAG) creates a scatterplot, where the data have been binned
%   into hexagonal bins. The length of the side of the hexagon at the center of each
%   bin is proportional to the number of observations that fall into that
%   bin. 
%
%   The input argument X (n x 2) contains the bivariate data; N is the
%   (approximate) number of bins in the variable that has the larger range;
%   and the optional argument FLAG (can be any value) maps the color of the hexagon 
%   to the probability density at that bin.

[n,p] = size(X);

% Find the range - the one with the longest range with have the 'longer'
% side of the hexagon. Use this to find the radius r.
rng = max(X) - min(X);
if rng(1) > rng(2)
    % Then the horizontal is longer.
    r = 2*rng(1)/(3*N);
   % Get the canonical hexagon.
    R = r*ones(1,6);
    theta = (0:60:300)*pi/180;
    % Convert to cartesian.
    [hexX,hexY] = pol2cart(theta,R);
    % Get the centers in x direction, used to generate mesh.
    % Putting some padding on either side to ensure that there are enoug
    % bins.
    xc1 = min(X(:,1))-r:3*r:max(X(:,1))+r;
    yc1 = min(X(:,2))-r:r*sqrt(3):max(X(:,2))+r;
    xc2 = min(X(:,1))-r+3*r/2:3*r:max(X(:,1))+r;
    yc2 = min(X(:,2))-r+r*sqrt(3)/2:r*sqrt(3):max(X(:,2))+r;
    [tx1,ty1] = meshgrid(xc1,yc1);
    [tx2,ty2] = meshgrid(xc2,yc2);
    CX = [tx1(:); tx2(:)];
    CY = [ty1(:); ty2(:)];
else
    % The vertical range is bigger and will have the longer 'side' of the
    % hexagon.
    r = 2*rng(2)/(3*N);
    % Get the canonical hexagon.
    R = r*ones(1,6);
    theta = (30:60:360)*pi/180;
    % Convert to cartesian.
    [hexX,hexY] = pol2cart(theta,R);
    % Get the centers in the y direction, used to generate mesh.
    xc1 = min(X(:,1))-r:sqrt(3)*r:max(X(:,1))+r;
    yc1 = min(X(:,2))-r:3*r:max(X(:,2))+r;
    xc2 = min(X(:,1))-r+r*sqrt(3)/2:r*sqrt(3):max(X(:,1))+r;
    yc2 = min(X(:,2))-r+3*r/2:3*r:max(X(:,2))+r;
    [tx1,ty1] = meshgrid(xc1,yc1);
    [tx2,ty2] = meshgrid(xc2,yc2);
    CX = [tx1(:); tx2(:)];
    CY = [ty1(:); ty2(:)];
end
% Now bin the data. 
freq = zeros(size(CX));
yn = zeros(size(1,50));
for i = 1:length(CX)
    in = inpolygon(X(:,1),X(:,2),hexX+CX(i),hexY+CY(i));
    freq(i) = length(find(in==1));
end

% Get the area of the canonical hexagon for density.
ar = polyarea(hexX,hexY);
% Get the correct n, just in case an observations wasn't binned. If on edge
% of polygon, then doesn't get counted.
n = sum(freq);

% Draw each non-zero bin with r proportional to the number of observations
% in the bin. 
% scale freqs between 0.1*r and r.
% Find all of the non-zero bin freqs.
ind = find(freq > 0);
a = min(freq(ind));
b = max(freq);
hold on
if nargin == 2
    % Then do just the plain plotting. 
    for i = 1:length(ind)
        j = ind(i);
        Rs = scale(freq(j),a,b,0.1*r,r);
        Rt = Rs*ones(1,6);
        [hexTx,hexTy] = pol2cart(theta,Rt);
        patch(hexTx+CX(j),hexTy+CY(j),'k');
    end
else
    % Then do the color mapped to density.
    % Convert to pdf values.
    pdf = freq/(n*ar);
    for i = 1:length(ind)
        j = ind(i);
        Rs = scale(freq(j),a,b,0.1*r,r);
        Rt = Rs*ones(1,6);
        [hexTx,hexTy] = pol2cart(theta,Rt);
        patch(hexTx+CX(j),hexTy+CY(j),pdf(j));
    end
    colorbar
    sum(pdf*ar)
end
hold off
axis equal

function nx = scale(x, a, b, c, d)
% This function converts a value x that orignally between a and b to
% one that is between c and d.
nx = (d - c)*(x - a)/(b - a) + c;

function Z = cshist2d(x,flag,h)
% CSHIST2D  Bivariate histogram.
%   W. L. and A. R. Martinez, 9/15/01
%   Computational Statistics Toolbox

%   Revision 1/02 - Fixed bug for axes - they were set at (-3,3) for the
%   standard normal. Removed the X and Y axes limits. 

%   Revision 1/02  - A user wrote in with a problem: the surface was not plotting. The
%   data had a covariance matrix where one variance was 1400 and the other
%   was 600. This resulted in 1 bin for each direction, using the default h. When the default
%   bin width calculation yields too few bins, the user needs to input 
%   the window widths, h. Put in some code to catch this.

%   Revision 4/05 - Not really changed in toolbox. Just changed for this
%   GUI. 

[n,p] = size(x);
if p ~= 2
    error('Must be bivariate data.')
end

if nargin == 2
    % then get the default bin width
    covm = cov(x);
    h(1) = 3.5*covm(1,1)*n^(-1/4);
    h(2) = 3.5*covm(2,2)*n^(-1/4);
else
    if length(h)~=2
        error('Must have two bin widths in h.')
    end
end

% Need bin origins.
bin0=[floor(min(x(:,1))) floor(min(x(:,2)))] - 0.05; 
% find the number of bins
nb1 = ceil((max(x(:,1))-bin0(1))/h(1));
nb2 = ceil((max(x(:,2))-bin0(2))/h(2));

% find the mesh
t1 = bin0(1):h(1):(nb1*h(1)+bin0(1) + 0.05);
t2 = bin0(2):h(2):(nb2*h(2)+bin0(2) + 0.05);
[X,Y] = meshgrid(t1,t2);
% Find bin frequencies.
[nr,nc] = size(X);
vu = zeros(nr-1,nc-1);
for i = 1:(nr-1)
   for j = 1:(nc-1)
      xv = [X(i,j) X(i,j+1) X(i+1,j+1) X(i+1,j)];
      yv = [Y(i,j) Y(i,j+1) Y(i+1,j+1) Y(i+1,j)];
      in = inpolygon(x(:,1),x(:,2),xv,yv);
      vu(i,j) = sum(in(:));
   end
end
Z = vu/(n*h(1)*h(2));

if flag == 1
    surf(Z)
    grid off
    axis tight
    set(gca,'YTickLabel',' ','XTickLabel',' ')
    set(gca,'YTick',0,'XTick',0)
elseif flag == 2
    % The Z matrix is obtained in Example 5.14
    bar3(Z,1)
    % Use some Handle Graphics.
    set(gca,'YTick',0,'XTick',0)
    grid off
    axis tight
else
    error('Flag must be 1 for surface plot or 2 for square bins.')
end


