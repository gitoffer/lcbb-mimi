function univgui(arg)
% UNIVGUI Distribution Shapes - Univariate
%
% This GUI function allows one to explore the univariate distributions in
% the data set. These are the distributions of the columns of the data
% matrix X.
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       univgui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','univgui');
if isempty(flg)
    % then create the gui
    dsulayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'dispbox')
    % Display the side-by-side boxplots.
    dispbox
elseif strcmp(arg,'disphist')
    % Display the histograms of the columns. These will be displayed in a
    % matrix-like layout.
    disphist
elseif strcmp(arg,'dispqq')
    % Display q-q plots of the columns of the data matrix. These will be
    % displayed in a matrix-like layout.
    dispqq
elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','univgui');
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
function dispbox
% This function displays the side-by-side boxplots.
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
tg = findobj('tag','univgui');
H = get(tg,'userdata');
% Get the chosen type of plot.
boxchoice = get(H.popbox,'value');
% Get the dimensions to plot.
dims = get(H.dimbox,'string');
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
% Now do the plots based on the choice.
switch boxchoice
    case 1
        % This is the regular boxplots
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: Boxplots')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
        boxplot(ud.X(:,dim));
    case 2
        % This is the nothed boxplots
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: Notched Boxplots')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
        boxplot(ud.X(:,dim),1);
    case 3
        % Box-percentile plot
        hf = boxprct(ud.X(:,dim));
        set(hf,'numbertitle','off','name','EDA: Box-Percentile Plot')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 4
        % Histplot
        hf = boxp(ud.X(:,dim),'hp');
        set(hf,'numbertitle','off','name','EDA: Histplots')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function disphist
% This function displays the histograms.
% The plots for this choice will depend on whether the user chooses to have
% plot all of the dimensions (shown in a plotmatrix format) or one
% dimension (shown in one axis only).
% 
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
tg = findobj('tag','univgui');
H = get(tg,'userdata');
% Get the chosen type of plot.
histchoice = get(H.pophist,'value');
% Get the dimensions to plot.
dims = get(H.dimhist,'string');
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
% Now do the plots based on the choice.
pp = length(dim);
% Get the layout of the subplots.
nr = round(sqrt(pp));
nc = ceil(pp/nr);
% Get the bandwidths. Will be a vector of bandwidths - based on number
% wanting to plot.
switch histchoice
    case 1
        % Use Normal reference rule (really Scott's rule)
        sig = std(ud.X(:,dim));
        bw = 3.5*sig*n^(-1/3);
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: Probability Density Histogram - Normal Reference Rule')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 2
        % Freedman-Diaconis Rule
        for i = 1:pp
            ti = dim(i);
            q = quartiles(ud.X(:,ti));
            IQR = q(3) - q(1);
            bw(i) = 2*IQR*n^(-1/3);
        end
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: Probability Density Histogram - Freedman/Diaconis Rule')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 3
        % Sturge's Rule
        k = round(1 + log2(n));
        rng = max(ud.X(:,dim)) - min(ud.X(:,dim));
        bw = rng/k;
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: Probability Density Histogram - Sturges Rule')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
        
end
% Now that we have the bandwidths - do the histogram and plots.
for i = 1:pp
    subplot(nr,nc,i);
    ti = dim(i);
    % Am going to cheat and convert bandwidth to number of bins. Then use
    % the hist function. Err on the side of too many bins.
    rng = max(ud.X(:,ti)) - min(ud.X(:,ti));
    k = ceil(rng/bw(i));
    [nuk,xk] = hist(ud.X(:,ti),k);
    h = xk(2) - xk(1);
    bar(xk,nuk/(n*h), 1, 'w')
    if isnumeric(ud.varlab)
        title(num2str(ud.varlab(ti)));
    elseif iscell(ud.varlab)
        title(ud.varlab{ti});
    end
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dispqq
% This function displays the q-q plots
% Get the data matrix. Get the GUI info.
ud = get(0,'userdata');
if isempty(ud.X)
    errordlg('You must load up some data first.')
    return
end
[n,p] = size(ud.X);
tg = findobj('tag','univgui');
H = get(tg,'userdata');
% Get the chosen type of plot.
qqchoice = get(H.popqqt,'value');
% Get the dimensions to plot.
dims = get(H.dimqq,'string');
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
% Now do the plots based on the choice.
pp = length(dim);
% Get the layout of the subplots.
nr = round(sqrt(pp));
nc = ceil(pp/nr);
% Get the bandwidths. Will be a vector of bandwidths - based on number
% wanting to plot.
% This will generate the random variables to plot against.
% This will be a matrix of values. 
randmat = zeros(n,pp);

switch qqchoice
    case 1
        % Normal distribution
        randmat = randn(n,pp);
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: QQ Plot - Normal Distribution')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 2
        % Exponential distribution
        % First estimate the parameters. Use those in the rng function.
        parmhat = expfit(ud.X(:,dim));
        for i = 1:pp
            ti = dim(i);
            randmat(:,i) = exprnd(parmhat(i),n,1);
        end
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: QQ Plot - Exponential Distribution')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 3
        % Gamma distribution
        for i = 1:pp
            ti = dim(i);
            phat = gamfit(ud.X(:,ti));
            randmat(:,i) = gamrnd(phat(1),phat(2),n,1);
        end
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: QQ Plot - Gamma Distribution')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 4
        % Chi-square distribution
        randmat = chi2rnd(n-1,n,pp);
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: QQ Plot - Chi-Square Distribution')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 5
        % Lognormal distribution
        for i = 1:pp
            ti = dim(i);
            phat = lognfit(ud.X(:,ti));
            randmat(:,i) = lognrnd(phat(1),phat(2),n,1);
        end
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: QQ Plot - Lognormal Distribution')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 6
        % Uniform distribution
        for i = 1:pp
            ti = dim(i);
            [ahat, bhat] = unifit(ud.X(:,ti));
            randmat(:,i) = unifrnd(ahat,bhat,n,1);
        end        
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: QQ Plot - Uniform Distribution')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
    case 7
        % Poisson distribution
        parmhat = poissfit(ud.X(:,dim));
        for i = 1:pp
            ti = dim(i);
            randmat(:,i) = poissrnd(parmhat(i),n,1);
        end
        hf = figure;
        set(hf,'numbertitle','off','name','EDA: QQ Plot - Poisson Distribution')
        % Upon figure close, this should delete from the array.
        set(hf,'CloseRequestFcn',...
            'tg = findobj(''tag'',''univgui''); H = get(tg,''userdata''); H.plots(find(H.plots == gcf)) = []; set(tg,''userdata'',H); delete(gcf)')
        H.plots = [H.plots, hf];
        set(tg,'userdata',H)
end
% Now that we have the distributions - do the qq plots.
for i = 1:pp
    subplot(nr,nc,i);
    ti = dim(i);
    qqplot(ud.X(:,ti),randmat(:,i));
    % get rid of the x and y axis labels
    xlabel(' '), ylabel(' ')
    if isnumeric(ud.varlab)
        title(num2str(ud.varlab(ti)));
    elseif iscell(ud.varlab)
        title(ud.varlab{ti});
    end
end    


%%%%%%%%%%%%%%%%%%%   HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%
function H = boxprct(X,vw)
%  BOXPRCT Box-Percentile Plot
%   

% Figure out what inputs were given.
if nargin == 1
    % Then just the plain boxplots.
    w = 2;
    varw = 0;
elseif strcmp(vw,'vw')
    varw = 1;
else
    error('Second argument can only be ''vw''')
end
if isnumeric(X) & varw==1
    error('Cannot do variable width boxplots when the sample sizes are the same.')
end
% Find the type of input argument x
if iscell(X)
    p = length(X);
    for i = 1:p
        % Get all of the sample sizes and the index for the median.
        n(i) = length(X{i});
    end
    if length(unique(n))==1 & varw==1
        error('Cannot do variable width boxplots when the sample sizes are the same.')
    end
    % Get the min and the max of the root n.
    maxn = max(sqrt(n));
    minn = min(sqrt(n));
else
    [n,p] = size(X);
end
% Find some of the things needed to plot them.
% Each boxplot will have a maximum width of 2 units.
ctr = 4:4:4*p;
H = figure; hold on
for i = 1:p
    % Extract the data.
    if iscell(X)
        x = sort(X{i});
    else
        x = sort(X(:,i));
        plain = 1;
    end
    if varw
        % Then it is a variable width boxplot.
        ns = sqrt(n(i));
        % Scale between 0.5 and 2.
        w = scale(ns, minn, maxn, 0.5, 2);
    end
    % Get the quartiles.
    q = quartiles(x);
    if length(n) ~= 1
        % Then we have different sample sizes.
        N = n(i);
    else
        N = n;
    end
    qinds = getk(N);
    KK = qinds(2);
    Lside = [ctr(i)-(1:KK)*w/(N+1), ctr(i)-(N+1-(KK+1:N))*w/(N+1)];
    Rside = [ctr(i)+(1:KK)*w/(N+1), ctr(i)+(N+1-(KK+1:N))*w/(N+1)];
    plot(Lside,x,'k', Rside,x,'k')
    % plot the quartiles.
    k1 = qinds(1);
    plot([ctr(i)-k1*w/(N+1),ctr(i)+k1*w/(N+1)],[q(1),q(1)],'k')
    k2 = qinds(2);
    plot([ctr(i)-k2*w/(N+1),ctr(i)+k2*w/(N+1)],[q(2),q(2)],'k')
    k3 = qinds(3);
    plot([ctr(i)-(N+1-(k3))*w/(N+1),ctr(i)+(N+1-(k3))*w/(N+1)],[q(3),q(3)],'k')
end
ax = axis;
axis([ctr(1)-2 ctr(end)+2 ax(3:4)])
set(gca,'XTickLabel',' ')
hold off

function K = getk(n)
% This function gets the index K for the median of a sample of size n.
K = zeros(1,3);
if rem(n,2)==0
    % then its even
    K(2) = n/2;
    ptrs = K(2)+1:n; 
else
    K(2) = (n+1)/2;
    ptrs = K(2):n;
end
% Get the index to the first quartile.
if rem(K(2),2) ==0
    % If the median is at an even index, then the halves will have even
    % sizes.
    K(1) = K(2)/2;
    K(3) = ptrs(K(1));
else
    K(1) = (K(2)+1)/2;
    K(3) = ptrs(K(1));
end

function H = boxp(X, vw)

%  BOXP  Boxplot and variations
%
%   EXAMPLES
%           boxp(x)      % Plots the plain boxplot for each col/cell of x
%           boxp(x,'vw') % Plots the variable width boxplots
%           boxp(x,'hp') % Plots the histplot

% Figure out what inputs were given.
if nargin == 1
    % Then just the plain boxplots.
    plain = 1;
    varw = 0;
    histp = 0;
    w = 2;
elseif strcmp(vw,'vw')
    plain = 0;
    varw = 1;
    histp = 0;
elseif strcmp(vw,'hp')
    plain = 0;
    varw = 0;
    histp = 1;
else
    error('Second argument can only be ''vw'' or ''hp''')
end
% Find the type of input argument x
if iscell(X)
    p = length(X);
    for i = 1:p
        % Get all of the sample sizes.
        n(i) = length(X{i});
    end
    % Get the min and the max of the root n.
    maxn = max(sqrt(n));
    minn = min(sqrt(n));
else
    [n,p] = size(X);
end
% Find some of the things needed to plot them.
% Each boxplot will have a maximum width of 2 units.
N = 4 + p-1 + 3*p;
ctr = 4:4:4*p;
Le = ctr - 1;
Re = ctr + 1;
H = figure; hold on
for i = 1:p
    % Extract the data.
    if iscell(X)
        x = X{i};
    else
        x = X(:,i);
    end
    % Get the quartiles.
    q = quartiles(x);
    % Get the outliers and adjacent values.
    [adv,outs] = getout(q,x);
    % Get the maximum width of the boxplot.
    if varw
        if length(n) == 1
            error('All sample sizes are equal. Do not do variable width boxplot.')
        end
        % Then it is a variable width boxplot.
        ns = sqrt(n(i));
        % Scale between 0.5 and 2.
        w = scale(ns, minn, maxn, 0.5, 2);
    end
    % Draw the boxes.
    if plain
        % If we have plain boxplots.
        % Draw the quartiles.
        plot([Le(i) Re(i)],[q(1),q(1)])
        plot([Le(i) Re(i)],[q(2),q(2)])
        plot([Le(i) Re(i)],[q(3),q(3)])
        % Draw the sides of the box
        plot([Le(i) Le(i)],[q(1),q(3)])
        plot([Re(i) Re(i)],[q(1),q(3)])
        % Draw the whiskers.
        plot([ctr(i) ctr(i)],[q(1),adv(1)], [ctr(i)-.25 ctr(i)+.25], [adv(1) adv(1)]) 
        plot([ctr(i) ctr(i)],[q(3),adv(2)], [ctr(i)-.25 ctr(i)+.25], [adv(2) adv(2)])
    elseif varw
        % If we have variable width boxplots.
        % Draw the quartiles.
        plot([ctr(i)-w ctr(i)+w],[q(1),q(1)])
        plot([ctr(i)-w ctr(i)+w],[q(2),q(2)])
        plot([ctr(i)-w ctr(i)+w],[q(3),q(3)])
        % Draw the sides of the box
        plot([ctr(i)-w ctr(i)-w],[q(1),q(3)])
        plot([ctr(i)+w ctr(i)+w],[q(1),q(3)])
        % Draw the whiskers.
        ww = scale(ns, minn, maxn, 0.1, 0.25);
        plot([ctr(i) ctr(i)],[q(1),adv(1)], [ctr(i)-ww ctr(i)+ww], [adv(1) adv(1)]) 
        plot([ctr(i) ctr(i)],[q(3),adv(2)], [ctr(i)-ww ctr(i)+ww], [adv(2) adv(2)])
    else
        % We must have the histplot. Plot widths at quartiles proportional
        % to the density estimate there.
        % Draw the quartiles - first get estimates of the density at each.
        for j = 1:3
            fhat(j) = cskern1d(x,q(j));
        end
        w1 = scale(fhat(1),min(fhat),max(fhat),0.5,2);
        w1 = w1/2;
        plot([ctr(i)-w1 ctr(i)+w1],[q(1),q(1)])
        w2 = scale(fhat(2),min(fhat),max(fhat),0.5,2);
        w2 = w2/2;
        plot([ctr(i)-w2 ctr(i)+w2],[q(2),q(2)])
        w3 = scale(fhat(3),min(fhat),max(fhat),0.5,2);
        w3 = w3/2;
        plot([ctr(i)-w3 ctr(i)+w3],[q(3),q(3)])
        % Plot the sides.
        plot([ctr(i)-w1 ctr(i)-w2],[q(1),q(2)])
        plot([ctr(i)+w1 ctr(i)+w2],[q(1),q(2)])
        plot([ctr(i)-w2 ctr(i)-w3],[q(2),q(3)])
        plot([ctr(i)+w2 ctr(i)+w3],[q(2),q(3)])
        % Draw the whiskers.
        plot([ctr(i) ctr(i)],[q(1),adv(1)], [ctr(i)-.25 ctr(i)+.25], [adv(1) adv(1)]) 
        plot([ctr(i) ctr(i)],[q(3),adv(2)], [ctr(i)-.25 ctr(i)+.25], [adv(2) adv(2)])
    end
    % Draw the outliers.
    plot(ctr(i)*ones(size(outs)), outs,'o')
    
    
end
ax = axis;
axis([Le(1)-2 Re(end)+2 ax(3:4)])
set(gca,'XTickLabel',' ')
hold off


function [adv,outs] = getout(q,x)
% This helper function returns the adjacent values and
% outliers.
x = sort(x);
n = length(x);
% Get the upper and lower limits.
iq = q(3) - q(1);
UL = q(3) + iq*1.5;
LL = q(2) - iq*1.5;
% Find any outliers.
ind = [find(x > UL); find(x < LL)];
outs = x(ind);
% Get the adjacent values. Find the
% points that are NOT outliers.
inds = setdiff(1:n,ind);
% Get their min and max.
adv = [x(inds(1)) x(inds(end))];

function nx = scale(x, a, b, c, d)
% This function converts a value x that is orignally between a and b to
% one that is between c and d.
nx = (d - c)*(x - a)/(b - a) + c;

function fhat = cskern1d(data,x)
n = length(data);
fhat = zeros(size(x));
h = 1.06*n^(-1/5);
for i=1:n
   f=exp(-(1/(2*h^2))*(x-data(i)).^2)/sqrt(2*pi)/h;
   fhat = fhat+f/(n);
end

function q = quartiles(x)

%   QUARTILES   Finds the three sample quartiles
%
%   Q = quartiles(X)
%   This returns the three sample quartiles as defined by Tukey,
%   Exploratory Data Analysis, 1977.

% First sort the data.
x = sort(x);
% Get the median.
q2 = median(x);
% First find out if n is even or odd.
n = length(x);
if rem(n,2) == 1
    odd = 1;
else
    odd = 0;
end
if odd
    q1 = median(x(1:(n+1)/2));
    q3 = median(x((n+1)/2:end));
else
    q1 = median(x(1:n/2));
    q3 = median(x(n/2:end));
end
q(1) = q1;
q(2) = q2;
q(3) = q3;
