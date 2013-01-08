function transformgui(arg,w)
% TRANSFORMGUI  Data Transformation GUI
%
% This GUI function tranforms the data that has been loaded using the
% LOADGUI. One can spherize the data (centered at the mean with identity
% covariance matrix) or apply transforms to the rows or columns of the data
% matrix. 
%
% One can call it from the edagui GUI or stand-alone from the command
% line. To call from the command line use
%
%       transformgui
%
%   Exploratory Data Analysis Toolbox, April 2005
%   Martinez and Martinez, Exploratory Data Analysis with MATLAB
%   CRC Press

% First set up the layout if it does not exist.
flg = findobj('tag','transformgui');
if isempty(flg)
    % then create the gui
    transformlayout
elseif nargin == 0
    % bring it forward
    figure(flg)
end

if nargin == 0
    arg = ' ';
end

if strcmp(arg,'sphere')
    % Then spherize the data.
    sphere
elseif strcmp(arg,'transrows')
    % Apply the transform to the rows of the data matrix.
    transrows    
elseif strcmp(arg,'transcols')
    % Apply the transform to the columns of the data matrix.
    transcols
elseif strcmp(arg,'restore')
    % Restore the original data set. Do some error checking here, in case
    % the file or variable do not exist in the directory or workspace.
    restore(w)
elseif strcmp(arg,'close')
    % in other gui's we will do some housekeeping. With this gui, we do not
    % have to do so. Obviously, the user will want to keep the data from
    % the loadgui for other applications. That is the purpose.
   tg = findobj('tag','transformgui');
   delete(tg)
end

function sphere
% This function will sphere the data. This means the data will now have a
% mean of 0 and a covariance matrix of 1.
ud = get(0,'userdata');
[n,p] = size(ud.X);
muhat = mean(ud.X);
[V,D] = eig(cov(ud.X));
Xc = ud.X - ones(n,1)*muhat;
Z = ((D)^(-1/2)*V'*Xc')';
% Reset the data to this sphered version.
ud.X = Z;
set(0,'userdata',ud);
uiwait(msgbox('Data set is successully sphered.','Data Transformation','modal'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function transrows
% This function will apply the transformation specified in the popupmenu to
% the rows of the data matrix. 
% Get the user data.
ud = get(0,'userdata');
% Get the handle information saved in the GUI - so we can access the menu.
tg = findobj('tag','transformgui');
H = get(tg,'userdata');
% Now get the choice of transform.
% 1 'Center at mean'
% 2 'Center at median'
% 3 'Scale using sigma'
% 4 'Scale using IQR'
% 5 'Center/Scale-mean/sigma'
% 6 'Center/Scale-median/IQR'
val = get(H.pop1,'value');
% apply to the rows - so let's do this by transposing
% And then working on columns always.
data = ud.X';
[n,p] = size(data);     % note that since this is the transpose, n and p are diff.
if val == 1
    % Center at the mean
    xbar = mean(data);
    Z = data - repmat(xbar, n, 1);
    ud.X = Z';      % equals tranpose because applied to rows.
    uiwait(msgbox('Rows are centered at the mean.','Data Transformation','modal'));
elseif val == 2
    % Center at the median
    med = median(data);
    Z = data - repmat(med,n,1);
    ud.X = Z';    
    uiwait(msgbox('Rows are centered at the median.','Data Transformation','modal'));
elseif val == 3
    % Scale using sigma
    sig = std(data);
    Z = data./repmat(sig,n,1);
    ud.X = Z';
    uiwait(msgbox('Rows are scaled by standard the deviation.','Data Transformation','modal'));
elseif val == 4
    % Scale using the IQR
    % Find the IQR for each column
    IQR = zeros(1,p);
    for i = 1:p
        % first find the quartiles
        q = quartiles(data(:,i));
        IQR(i) = q(3) - q(1);
    end
    Z = data./repmat(IQR,n,1);
    ud.X = Z';
    uiwait(msgbox('Rows are scaled by the interquartile range.','Data Transformation','modal'));
elseif val == 5
    % Find z scores
    % Center at the mean
    xbar = mean(data);
    Z = data - repmat(xbar, n, 1);
    % Scale using sigma
    sig = std(data);
    Z = Z./repmat(sig,n,1);
    ud.X = Z';
    uiwait(msgbox('Rows are centered at the mean and scaled by the standard deviation.','Data Transformation','modal'));
elseif val == 6
    % Center/scale using the median and iqr
    % Center at the median
    med = median(data);
    Z = data - repmat(med,n,1);
    % Scale using the IQR
    % Find the IQR for each column
    IQR = zeros(1,p);
    for i = 1:p
        % first find the quartiles
        q = quartiles(data(:,i));
        IQR(i) = q(3) - q(1);
    end
    Z = Z./repmat(IQR,n,1);
    ud.X = Z';
    uiwait(msgbox('Rows are centered at the median and scaled by the interquartile range.','Data Transformation','modal'));
end
% Reet the data in the userdata
set(0,'userdata',ud)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function transcols
% This function will apply the transformation specified in the popupmenu to
% the rows of the data matrix. 
% Get the user data.
ud = get(0,'userdata');
% Get the handle information saved in the GUI - so we can access the menu.
tg = findobj('tag','transformgui');
H = get(tg,'userdata');
% Now get the choice of transform.
% 1 'Center at mean'
% 2 'Center at median'
% 3 'Scale using sigma'
% 4 'Scale using IQR'
% 5 'Center/Scale-mean/sigma'
% 6 'Center/Scale-median/IQR'
val = get(H.pop1,'value');
% apply to the columns so no need to transpose
data = ud.X;
[n,p] = size(data);     % note that since this is the transpose, n and p are diff.
if val == 1
    % Center at the mean
    xbar = mean(data);
    Z = data - repmat(xbar, n, 1);
    ud.X = Z;      % equals tranpose because applied to rows.
    uiwait(msgbox('Columns are centered at the mean.','Data Transformation','modal'));
elseif val == 2
    % Center at the median
    med = median(data);
    Z = data - repmat(med,n,1);
    ud.X = Z;    
    uiwait(msgbox('Columns are centered at the median.','Data Transformation','modal'));
elseif val == 3
    % Scale using sigma
    sig = std(data);
    Z = data./repmat(sig,n,1);
    ud.X = Z;
    uiwait(msgbox('Columns are scaled by standard the deviation.','Data Transformation','modal'));
elseif val == 4
    % Scale using the IQR
    % Find the IQR for each column
    IQR = zeros(1,p);
    for i = 1:p
        % first find the quartiles
        q = quartiles(data(:,i));
        IQR(i) = q(3) - q(1);
    end
    Z = data./repmat(IQR,n,1);
    ud.X = Z;
    uiwait(msgbox('Columns are scaled by the interquartile range.','Data Transformation','modal'));
elseif val == 5
    % Find z scores
        % Center at the mean
    xbar = mean(data);
    Z = data - repmat(xbar, n, 1);
    % Scale using sigma
    sig = std(data);
    Z = Z./repmat(sig,n,1);
    uiwait(msgbox('Columns are centered at the mean and scaled by the standard deviation.','Data Transformation','modal'));
    ud.X = Z;
elseif val == 6
    % Center/scale using the median and iqr
        % Center at the median
    med = median(data);
    Z = data - repmat(med,n,1);
    % Scale using the IQR
    % Find the IQR for each column
    IQR = zeros(1,p);
    for i = 1:p
        % first find the quartiles
        q = quartiles(data(:,i));
        IQR(i) = q(3) - q(1);
    end
    Z = Z./repmat(IQR,n,1);
    ud.X = Z;
    uiwait(msgbox('Columns are centered at the median and scaled by the interquartile range.','Data Transformation','modal'));
end
% Reet the data in the userdata
set(0,'userdata',ud)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restore(w)
% In this function, we will restore the original data set. We must do an
% error check to see if the variable is still in the directory or
% workspace.
ud = get(0,'userdata');
try
    if ~isempty(ud.loadworkspace)
        % Then user loaded data from the workspace.
        str = ['ud = get(0,''userdata'');' 'ud.X = ' ud.loadworkspace '; ' 'set(0,''userdata'',ud)'];
        evalin('base',str)
        uiwait(msgbox('Data set is successully restored from workspace.','Data Transformation','modal'));
    elseif ~isempty(ud.loadfile)
        % Then user loaded data from the file.
        data = load(ud.loadfile);
        ud.X = data;
        set(0,'userdata',ud);
        uiwait(msgbox('Data set is successully restored from file.','Data Transformation','modal'));
    else
        errordlg('Pointers to data are lost - unable to restore the data.')
    end
catch
    errordlg('Unable to restore original data. Ensure that the data set is still in the specified directory or in the workspace.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

