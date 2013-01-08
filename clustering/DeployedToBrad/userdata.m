function ud = userdata
% This file contains information common to all of the GUIs. In other words,
% it has the list of fields in the structure that holds global information
% that is used in all GUIs. This will be used for configuration management
% once the GUIs are done.

% NOTE: The 'ud' structure contains global variables and will be saved in
% the root 'userdata'. The 'H' structure in various functions contains
% local variables and will be saved in the GUI 'userdata'.

% ud.X = [];
% ud.tmp = [];          % This field is to temporarily hold stuff.
% ud.classlab = [];
% ud.caselab = [];
% ud.varlab = [];
% ud.loadworkspace = [];
% ud.loadfile = [];
% ud.groupscolor = [];    
% ud.obscolor = [];     
% ud.linkap = [];
% ud.linkptrap = [];    % this has handles for linked plots.
% ud.brush = [];        % These are the plots that can be brushed.
% ud.brushptr = [];     % Index of pointers to brushable plots. 
% ud.highlight = [];
% ud.dimred = 'X';       % Starts off with X, then adds PCA, ISOMAP, LLE, HLLE
% ud.gt = [];     
% ud.gtstop = [];
% ud.guis = [];         % Not really needed right now.
% ud.pgt = [];   
% ud.pgtstop = [];
% ud.ppeda = [];  
% ud.pca = [];    
% ud.LLE = [];    
% ud.hLLE = [];   
% ud.mds = [];
% ud.cmds = [];
% ud.isomap = []; 
% ud.kmeansids = [];  
% ud.agcids = [];    
% ud.mbcids = [];    

% Current data that will be operated upon. It can
% either be transformed or not. However, it is NOT data that has been
% reduced in dimensionality.
ud.X = [];
ud.tmp = [];        % This temporarily holds stuff - mainly for loading from workspace.

% Class labels, if they exist. This is an optional
% field for the user to enter. There are 'n' of them.
ud.classlab = [];

% THE FOLLOWING WILL HAVE TO BE GIVEN THEIR DEFAULTS ONCE THE DATA MATRIX
% IS LOADED - WHEN WE HAVE THE VALUES FOR n AND p.
% Case labels, if they exist. This is an optional field. There are n of
% them. The default will be 1:n as a cell array of strings.
ud.caselab = [];
ud.varlab = [];


% These are strings containing the variable name or path to the file, 
% so we can reload the information when the RESTORE button is pushed.
% These are used when one wants to go from transformed data back to the
% original data.
ud.loadworkspace = [];
ud.loadfile = [];
 
% % The following two fields are used when using the brushing and linking
% % GUI. The user can select groups to color or observations to color. Only
% % one can be used at a time. Each of these is a colormap. Default will be
% % black - which is all 0's.
% ud.groupscolor = [];    % g by 3 colormap, where g is the number of groups
% ud.obscolor = [];       % n by 3 colormap

% This is an important field. 
% Note that brushing and
% linking will involve only the GEDA GUI figures and the clustering ones.
% These are the only ones that have appropriate plots. We will not be
% linking/brushing grand tour plots. At least at this time. 
% Plots that can be brushed: 2-D scatter, rectangle plot, Reclus
% This needs to be updated when the figure windows are closed.
ud.brush = [];
% This contains an index of handles to FIGURE windows that can be brushed.
% This will be used to  build the popupmenu. 
ud.brushptr = [];
ud.highlight = [];  % array of handles to highlighted axes - scatterplot-type. 
% All link/brush plots have this - except Andrews and parallel coordinate
% plots.

% This contains an array of handles for Andrews' and Parallel coordinate
% plots that are open. For now, these are only from the GEDA GUI - not data
% tours. It will have n rows and a variable number of columns (the user
% might have more than one parallel coords plot, for example). Plots that
% can be linked: all brushable plots, Andrews and parallel coords. 
% I guess with the plotmatrix version, we will have p^2
% (approx) columns - one for each axes that is plotted. Also, will have
% corresponding number in the ud.linkptr array.
% This needs to be updated when the figure windows are closed.
% Note that in andrews and parallel, each observation has a line. So there
% will be n object handles for each plot.
ud.linkap = [];
ud.linkptrap = [];    % this has handles for linked plots.

% May be used later.
ud.guis = [];

% This is a cell array of strings that contains data types that have been
% reduced in dimensionality. This will provide choices to the user in doing
% clustering. AND maybe in GEDA.
ud.dimred = {'X'};  % PCA, ISOMAP, LLE, HLLE

% These have the projection matrices. Can be used to project the data 
% if the user wants to explore using something else. 
ud.gt = [];     % p by k matrix
ud.gtstop = [];     % flags to indicate starting/stopping tour
ud.pgtstop = [];
ud.pgt = [];    % p by 2 matrix (pseudo grand tour)
ud.ppeda = [];  % p by 2 matrix (current projection only)
ud.pca = [];    % p by k matrix

% These have the actual coordinates in reduced d-dimensional space.
ud.isomap = []; % ISOMAP coordinates
ud.mds = [];    % metric/nonmetric MDS coordinates
ud.LLE = [];    % Projection ?? 
ud.hLLE = [];   % Projection ??
ud.cmds = [];

% These have cluster IDs for the various methods.
ud.kmeansids = [];  % n cluster IDs from k-means
ud.agcids = [];     % n cluster IDs from agglomerative clustering
ud.mbcids = [];     % n cluster IDs from model-based clustering





