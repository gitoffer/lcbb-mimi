function ppedagui(arg)
% PPEDAGUI  Projection Pursuit Exploratory Data Analysis
%
% This GUI function drives the Projection Pursuit EDA methodology. In
% projeciton pursuit, one searches for 2-D projections where structure can
% be found. Structure can mean many things, but the most common meaning is
% a departure from normality. 
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       ppedagui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','ppedagui');
if isempty(flg)
    % then create the gui
    ppedalayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end
if strcmp(arg,'startppeda')
    % Start the PPEDA process.
    ud = get(0,'userdata');
    startppeda(ud.X)
    
elseif strcmp(arg,'grapheda')
    % Bring up the graphical EDA GUI
    gedagui
    
elseif strcmp(arg,'anothstruct')
    % Run structure removal. Recall the PPEDA function with this data. Keep
    % using current settings. If user wants to redo them then they have to
    % start all over. the START button will work only with ud.X.
    % X = csppstrtrem(Z,a,b)    Be careful with the X and Z here. Note that
    % the input Z here is sphereized data.
    % Call startppeda function in this GUI with this new X
    ud = get(0,'userdata');
    % sphere the data
    Z = sphere(ud.X);
    % remive the structure
    X = csppstrtrem(Z,ud.ppeda(:,1),ud.ppeda(:,2));
    % The following will reset the projection to the current one.
    % get the PPEDA projection.
    % Let's sphere it just in case.
    Z = sphere(X);
    startppeda(X)
    
elseif strcmp(arg,'dataout')
    % Export projected PPEDA data to the workspace.
    % First get the data and project.
    ud = get(0,'userdata');
    if ~isempty(ud.ppeda)
        Z = sphere(ud.X);
        data = Z*ud.ppeda;
    else
        errordlg('You have not explored the data yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Data from Current Projection Plane to Workspace';
    def = {'data'};
    saveinfo(promptstrg,titlestrg,def,data)
elseif strcmp(arg,'projout')
    % Export projection matrix from the grand tour to the workspace.
    ud = get(0,'userdata');
    if ~isempty(ud.ppeda)
        data = ud.ppeda;
    else
        errordlg('You have not explored the data yet.')
        return
    end
    promptstrg = 'Specify variable name:';
    titlestrg = 'Output Current Projection to Workspace';
    def = {'projection'};
    saveinfo(promptstrg,titlestrg,def,data)

elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
    tg = findobj('tag','ppedagui');
    % No other open plots on this one.
    delete(tg)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function startppeda(X)
% This gets the required information and then does the PPEDA
ud = get(0,'userdata');
tg = findobj('tag','ppedagui');
H = get(tg,'userdata');
axes(H.axindex)
cla
axes(H.axproj)
cla
% Get all of the edit box stuff.
ppstep = str2double(get(H.step,'string'));
if ppstep <= 0 
    errordlg('The step size must be greater than 1.')
    return
end
trials = round(str2double(get(H.trials,'string')));
if trials < 1
    errordlg('The number of trials must be greater than or equal to 1.')
    return
end
nohits = round(str2double(get(H.nohits,'string')));
if nohits <= 1
    errordlg('The number of no-hits must be greater than 1.')
    return
end
% Get type of index.
indtyp = get(H.index,'value');
% Value = 1 means Chi-square, Value = 2 means Moment.
if indtyp == 1
    ppi = 'chi';
else
    ppi = 'mom';
end
% spherize the data.
Z = sphere(X);
[as,bs,ppm] = ppeda(Z,ppstep,nohits,trials,ppi);
ud.ppeda = [as(:),bs(:)];

% save the projections to the userdata
set(0,'userdata',ud)

% Note that the projections are over-written. The user must save to the
% workspace for other structures. The user can call up the GEDA GUI and
% view the current restults. (so it is good that we are saving to the
% userdata first.) The user can then run it again, view it again, etc. 
ud = get(0,'userdata');
ud.dimred = unique([ud.dimred,{'PPEDA'}]);
% reset the popupmenu on the clustering/GEDA GUIs if open.
updatemenu(ud.dimred)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveinfo(promptstrg,titlestrg,def,data)

% data is the information to be saved to the workspace
answer = inputdlg(promptstrg,titlestrg,1,def);
if ~isempty(answer)
	assignin('base',answer{1},data)
% else
% 	assignin('base','data,H.data')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [as,bs,ppm] = ppeda(Z,c,half,m,ppi)
% PPEDA Projection pursuit exploratory data analysis.
% Special version for GUI. Includes graphics.

% Get the necessary graphical stuff.
tg = findobj('tag','ppedagui');
H = get(tg,'userdata');
%   H.axproj is the handle to the scatterplot projection
%   H.axindex is the handle to the index value plot

% set up line handles
axes(H.axindex)
Hindex = line('xdata',nan,'ydata',nan,'linestyle','-');
axes(H.axproj)
Hscatt = line('xdata',nan,'ydata',nan,'linestyle','.');

% Set up some of the handle graphics properties of the figure/axes
set(Hindex,'erasemode','xor');
% set(Hscatt,'erasemode','xor');
set(H.fig,'backingstore','off')
set(H.axindex,'drawmode','fast','ytick',[],...
    'yticklabel',' ')
set(H.axproj,'drawmode','fast')

% get the necessary constants
[n,p]=size(Z);
maxiter = 200;
cs=c;
cstop = 0.0001;
as = zeros(p,1);	% storage for the information
bs = zeros(p,1);
ppm = realmin;


% find the probability of bivariate standard normal over
% each radial box.
fnr=inline('r.*exp(-0.5*r.^2)','r');
ck=ones(1,40);
ck(1:8)=quadl(fnr,0,sqrt(2*log(6))/5)/8;
ck(9:16)=quadl(fnr,sqrt(2*log(6))/5,2*sqrt(2*log(6))/5)/8;
ck(17:24)=quadl(fnr,2*sqrt(2*log(6))/5,3*sqrt(2*log(6))/5)/8;
ck(25:32)=quadl(fnr,3*sqrt(2*log(6))/5,4*sqrt(2*log(6))/5)/8;
ck(33:40)=quadl(fnr,4*sqrt(2*log(6))/5,5*sqrt(2*log(6))/5)/8;

switch ppi
    case 'chi'
        for i=1:m  % m 
            % generate a random starting plane
            % this will be the current best plane
            a=randn(p,1);
            mag=sqrt(sum(a.^2));
            astar=a/mag;
            b=randn(p,1);
            bb=b-(astar'*b)*astar;
            mag=sqrt(sum(bb.^2));
            bstar=bb/mag;
            clear a mag b bb
            % find the projection index for this plane
            % this will be the initial value of the index
            ppimax = csppind(Z,astar,bstar,n,ck);
            % keep repeating this search until the value c becomes 
            % less than cstop or until the number of iterations exceeds maxiter
            mi=0;		% number of iterations
            h = 0;	% number of iterations without increase in index
            c=cs;
            % get arrays for plotting
            axes(H.axindex)
            
            PPI = [];
            while (mi < maxiter) & (c > cstop)	% Keep searching
                PPI = [PPI, ppimax];
                axis([1 maxiter 0 ppimax*1.5])
                set(Hindex,'xdata',1:(mi+1),'ydata',PPI);
                XTmp = Z*[astar(:),bstar(:)]; 
                set(Hscatt,'xdata',XTmp(:,1), 'ydata',XTmp(:,2));
                drawnow;
                % generate a p-vector on the unit sphere
                v=randn(p,1);
                mag=sqrt(sum(v.^2));
                v1=v/mag;
                % find the a1,b1 and a2,b2 planes
                t=astar+c*v1;
                mag = sqrt(sum(t.^2));
                a1=t/mag;
                t=astar-c*v1;
                mag = sqrt(sum(t.^2));
                a2 = t/mag;
                t = bstar-(a1'*bstar)*a1;
                mag = sqrt(sum(t.^2));
                b1 = t/mag;
                t = bstar-(a2'*bstar)*a2;
                mag = sqrt(sum(t.^2));
                b2 = t/mag;
                ppi1 = csppind(Z,a1,b1,n,ck);
                ppi2 = csppind(Z,a2,b2,n,ck);
                [mp,ip]=max([ppi1,ppi2]);
                if mp > ppimax	% then reset plane and index to this value
                    eval(['astar=a' int2str(ip) ';']);
                    eval(['bstar=b' int2str(ip) ';']);
                    eval(['ppimax=ppi' int2str(ip) ';']);
                else
                    h = h+1;	% no increase 
                end
                mi=mi+1;
                if h==half	% then decrease the neighborhood
                    c=c*.5;
                    h=0;
                end
            end
            % This is the best over all projections.
            if ppimax > ppm
                % save the current projection as a best plane
                as = astar;
                bs = bstar;
                ppm = ppimax;
            end
            disp(['Trial =' int2str(i) '  Index =' num2str(ppimax)])

        end
        disp(['Best projection over all trials has an index of ' num2str(ppm)])
        % display the results
        helpdlg({'PPEDA is finished.'},'PPEDA Status')

    case 'mom'
        for i=1:m  % m 
            % generate a random starting plane
            % this will be the current best plane
            a=randn(p,1);
            mag=sqrt(sum(a.^2));
            astar=a/mag;
            b=randn(p,1);
            bb=b-(astar'*b)*astar;
            mag=sqrt(sum(bb.^2));
            bstar=bb/mag;
            clear a mag b bb
            % find the projection index for this plane
            % this will be the initial value of the index
            Za = Z*astar;
            Zb = Z*bstar;
            ppimax = pimom(Za,Zb);
            % keep repeating this search until the value c becomes 
            % less than cstop or until the number of iterations exceeds maxiter
            mi=0;		% number of iterations
            h = 0;	% number of iterations without increase in index
            c=cs;
            % get arrays for plotting
            axes(H.axindex)
            
            PPI = [];
            while (mi < maxiter) & (c > cstop)	% Keep searching
                PPI = [PPI, ppimax];
                axis([1 maxiter 0 ppimax*1.5])
                set(Hindex,'xdata',1:(mi+1),'ydata',PPI);
                XTmp = Z*[astar(:),bstar(:)]; 
                set(Hscatt,'xdata',XTmp(:,1), 'ydata',XTmp(:,2));
                drawnow;
                
                % generate a p-vector on the unit sphere
                v=randn(p,1);
                mag=sqrt(sum(v.^2));
                v1=v/mag;
                % find the a1,b1 and a2,b2 planes
                t=astar+c*v1;
                mag = sqrt(sum(t.^2));
                a1=t/mag;
                t=astar-c*v1;
                mag = sqrt(sum(t.^2));
                a2 = t/mag;
                t = bstar-(a1'*bstar)*a1;
                mag = sqrt(sum(t.^2));
                b1 = t/mag;
                t = bstar-(a2'*bstar)*a2;
                mag = sqrt(sum(t.^2));
                b2 = t/mag;
                ppi1 = pimom(Z*a1,Z*b1);
                ppi2 = pimom(Z*a2,Z*b2);
                [mp,ip] = max([ppi1,ppi2]);
                if mp > ppimax	% then reset plane and index to this value
                    eval(['astar=a' int2str(ip) ';']);
                    eval(['bstar=b' int2str(ip) ';']);
                    eval(['ppimax=ppi' int2str(ip) ';']);
                else
                    h = h+1;	% no increase 
                end
                mi=mi+1;
                if h==half	% then decrease the neighborhood
                    c=c*.5;
                    h=0;
                end
            end
            if ppimax > ppm
                % save the current projection as a best plane
                as = astar;
                bs = bstar;
                ppm = ppimax;
            end
            disp(['Trial =' int2str(i) '  Index=' num2str(ppimax)])
            
        end
        disp(['Best projection over all trials has an index of ' num2str(ppm)])
        % display the results
        helpdlg({'PPEDA is finished.'},'PPEDA Status')
        
    otherwise
        error('PPI must be ''mom'' or ''chi''')
end

function pim = pimom(zalpha, zbeta)

% PIMOM     Projection Pursuit - Moment Index
% 
% PIM = PIMOM(ZALPHA, ZBETA)
% This function calculates the moment index for projection pursuit
% exploratory data analysis. The inputs ZALPHA and ZBETA are vectors that
% contain the observations projected onto the alpha and beta coordinates.
% The output is the value of the projection pursuit index.

n = length(zalpha);
% Get the values raised to the needed powers.
za2 = zalpha.^2;
zb2 = zbeta.^2;
za3 = zalpha.^3;
zb3 = zbeta.^3;
za4 = zalpha.^4;
zb4 = zbeta.^4;
% Get the coefficients.
c1 = n/((n-1)*(n-2));
c2 = (n*(n+1))/((n-1)*(n-2)*(n-3));
c3 = (3*(n-1)^3)/(n*(n+1));
c4 = (n-1)^3/(n*(n+1));
% Get all of the terms.
k30 = sum(za3)*c1;
k03 = sum(zb3)*c1;
k31 = sum(za3.*zbeta)*c2;
k13 = sum(zb3.*zalpha)*c2;
k04 = (sum(zb4) - c3)*c2;
k40 = (sum(za4) - c3)*c2;
k22 = (sum(za2.*zb2) - c4)*c2;
k21 = sum(za2.*zbeta)*c1;
k12 = sum(zb2.*zalpha)*c1;
% Get the value:
t1 = k30^2 +3*k21^2 + 3*k12^2 + k03^2;
t2 = k40^2 + 4*k31^2 + 6*k22^2 + 4*k13^2 + k04^2;
pim = (t1 + t2/4)/12;

function ppi = csppind(x,a,b,n,ck)
% CSPPIND Chi-square projection pursuit index.
%   
%   PPI = CSPPIND(Z,ALPHA,BETA,N,CK)
%   This finds the value of the projection pursuit index
%   for a plane spanned by the column vectors ALPHA and
%   BETA. The vector CK contains the bivariate standard
%   normal probabilities for radial boxes. CK is usually
%   found in the function CSPPEDA. The matrix Z is the
%   sphered or standardized version of the data.
%
%   See also CSPPEDA, CSPPSTRTREM

%   W. L. and A. R. Martinez, 9/15/01
%   Computational Statistics Toolbox 

z=zeros(n,2);
ppi=0;
pk=zeros(1,48);
eta = pi*(0:8)/36;
delang=45*pi/180;
delr=sqrt(2*log(6))/5;
angles=0:delang:(2*pi);
rd = 0:delr:5*delr;
nr=length(rd);
na=length(angles);

for j=1:9
   % find rotated plane
   aj=a*cos(eta(j))-b*sin(eta(j));
   bj=a*sin(eta(j))+b*cos(eta(j));
   % project data onto this plane
   z(:,1)=x*aj;
   z(:,2)=x*bj;
   % convert to polar coordinates
   [th,r]=cart2pol(z(:,1),z(:,2));
   % find all of the angles that are negative
	ind = find(th<0);
	th(ind)=th(ind)+2*pi;
   % find # points in each box
   for i=1:(nr-1)	% loop over each ring
      for k=1:(na-1)	% loop over each wedge
         ind = find(r>rd(i) & r<rd(i+1) & th>angles(k) & th<angles(k+1));
         pk((i-1)*8+k)=(length(ind)/n-ck((i-1)*8+k))^2/ck((i-1)*8+k);
      end
   end
   % find the number in the outer line of boxes
   for k=1:(na-1)
      ind=find(r>rd(nr) & th>angles(k) & th<angles(k+1));
      pk(40+k)=(length(ind)/n-(1/48))^2/(1/48);
   end
   ppi=ppi+sum(pk);
end
ppi=ppi/9;

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

