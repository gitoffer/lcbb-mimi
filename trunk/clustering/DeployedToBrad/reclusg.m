function [Hline, Haxs] = reclusg(cluslabs)
% SPECIAL VERSION FOR GUI.
% Hline = reclus(cluslabs)

% 0. Set up the parent rectangle. Note that we will split on the longer side of 
%   the rectangle according to the proportion that is in each group.
clus(1).x = 0;      % This is the x,y coordinates of the lower left corner of the rectangle
clus(1).y = 0;
clus(1).w = 100;
clus(1).h = 50;

% 1. Find all of the points in each cluster and the corresponding proportion.
n = length(cluslabs);   % number of data points.
uniqlabs = unique(cluslabs);
nc = length(uniqlabs);  % get the number of clusters
prop = zeros(1,nc);     % find the proportion in each one
for i = 1:nc
    ind = find(cluslabs==uniqlabs(i));
    prop(i) = length(ind)/n;
end

% 2. Order the proportions - ascending.
[sprop,ind] = sort(prop);
% sort the uniqlabs according to this sort order, so we keep the correpondence between
% proportion and the cluster label.
uniqlabs = uniqlabs(ind);
% store these proportions in the rectangle.
clus(1).prop = sprop;
% This will contain all of the cluster labels corresponding to the proportions.
clus(1).label = uniqlabs;  
% Set up a vector of indices to rectangles that still need splitting.
% note that these point to the records in the structure.
spliti = 1;

% For later plotting, keep a vector of indices to the final rectangles
% in the structure.
frect = [];

% PARTITION THE RECTANGLES INTO CHILDREN
% 3. Partition the proportions into 2 groups. If there are an odd number of clusters,
%   then put more of the clusters into the 'left/lower' group.
while ~isempty(spliti)
    % Split the remaining rectangles into children.
    ns = length(spliti);
    newsplit = [];      % use to store indices of rectangles that still need splitting.
    for i = 1:ns
        % split each one. Get the indices to these new rectangles.
        Li = length(clus) + 1;  
        Ri = Li + 1;
        % get the index to the parent that we are splitting
        pari = spliti(i);
        % get the information about the parent.
        propp = clus(pari).prop;
        xp = clus(pari).x;
        yp = clus(pari).y;
        wp = clus(pari).w;
        hp = clus(pari).h;
        labp = clus(pari).label;
        % Split the proportions.
        nL = ceil(length(propp)/2);   % tells how many in the lower/left child
        clus(Li).prop = propp(1:nL);
        clus(Ri).prop = propp((nL+1):end);
        % put these into the structure fields.
        % NOTE: We have to normalize the proportions based on the parent!!
        propleft = sum(clus(Li).prop)/sum(propp);
        propright = sum(clus(Ri).prop)/sum(propp);
        clus(Li).label = labp(1:nL);
        clus(Ri).label = labp((nL+1):end);
        if length(clus(Li).prop) > 1
            % then will have to split on the next round.
            newsplit = [newsplit Li];
        else    % it is a final rectangle.
            frect = [frect Li];
        end
        if length(clus(Ri).prop) > 1
            % then have to split on next round.
            newsplit = [newsplit Ri];
        else    % it is a final rectangle.
            frect = [frect Ri];
        end
        % split based on the longer dimension
        if wp > hp
            % Then split on the x dimension.
            % Get the left child.
            % Lower left corner is the same.
            % Height is the same.
            clus(Li).x = xp;
            clus(Li).y = yp;
            clus(Li).h = hp;
            % width is proportional to the size
            clus(Li).w = wp*propleft;
            % Get the right child.
            % Lower left corner is offset in x from parent.
            % Height is the same. Y coordinate is the same.
            clus(Ri).x = xp+wp*propleft;
            clus(Ri).y = yp;
            clus(Ri).h = hp;
            % width is proportional to the size
            clus(Ri).w = wp*propright;
        else
            % Then split on the y dimension.
            % Get the left child.
            % Lower left corner is the same.
            % Width is the same.
            clus(Li).x = xp;
            clus(Li).y = yp;
            clus(Li).w = wp;
            % Height is proportional to the size
            clus(Li).h = hp*propleft;
            % Get the right child.
            % x coordinate is the same.
            clus(Ri).x = xp;
            % y is offset from left child.
            clus(Ri).y = yp + hp*propleft;
            % height is proportional to size
            clus(Ri).h = hp*propright;
            % width is the same
            clus(Ri).w = wp;
        end
    end         % For i equals the rectangles that need to be split.
    % reset the vector of pointers to the rectangles that need splitting.
    spliti = newsplit;

end     % while loop

% NOW FIND THE POINTS IN EACH CLUSTER - PLOT
% 7. Find all of the points in each of the clusters.
% 8. Use meshgrid to find a regular mesh to plot them in. Plot the points in ascending
%   order of the labels or observation numbers.
% 9. Use 'text' to plot - save the handles. 

% First find the regular mesh to plot the points.        
for i = 1:length(frect)
    flab = clus(frect(i)).label;
    xf = clus(frect(i)).x;
    yf = clus(frect(i)).y;
    wf = clus(frect(i)).w;
    hf = clus(frect(i)).h;
    % Find the number of points that are in this class.
    inds = find(cluslabs == flab);
    npts = length(inds);
    fac(1) = floor(sqrt(npts));
    fac(2) = ceil(npts/fac(1));  % this should give more points than what we need.
    % Put more points in the longer dimension.
    [mf,imax] = max(fac);
    [mf,imin] = min(fac);
    if wf > hf
        xpts = linspace(xf, xf + wf, fac(imax) + 2);
        ypts = linspace(yf, yf + hf, fac(imin) + 2);
    else
        xpts = linspace(xf, xf + wf, fac(imin) + 2);
        ypts = linspace(yf, yf + hf, fac(imax) + 2);
    end
    % now we need to throw out the first and last points - on the edges of the rectangle.
    xpts([1,end]) = [];
    ypts([1,end]) = [];
    % NOw get the meshgrid.
    [Xf, Yf] = meshgrid(xpts, ypts);
    Xf = flipud(Xf);
    Yf = flipud(Yf);
    % make them into column vectors and keep only npts of them.
    Xf = Xf(:);
    Yf = Yf(:);
    if length(Xf) > npts    
        Xf((npts+1):end) = [];
        Yf((npts+1):end) = [];
    end
    % store the stuff in there to plot later on.
    clus(frect(i)).xpts = Xf;
    clus(frect(i)).ypts = Yf;
    % store the indices to points that belong in the cluster.
    clus(frect(i)).inds = inds;
end

% NOW DO THE PLOTTING
% NOTE THAT THIS IS THE ONLY CASE FOR THE GUI VERSION. 
Htxt = [];
t = (1:n)';
plotsym = 'o';
% do the plotting
axis([0 100 0 50])
Hline = [];
rectangle('Position',[clus(1).x clus(1).y clus(1).w clus(1).h])
% the following is to get the right positions and index numbers in order to
% do a single plot command, and get the handle back.


indall = [];
xall = [];
yall = [];
for i = 1:length(frect)
    ti = frect(i);
    rectangle('Position',[clus(ti).x clus(ti).y clus(ti).w clus(ti).h])
%     Htmp = text( clus(ti).xpts, clus(ti).ypts, plotsym );
    indall = [indall; clus(ti).inds(:)];
    xall = [xall; clus(ti).xpts(:)];
    yall = [yall; clus(ti).ypts(:)];
end
% now sort on the indexes so they match the other plots.
[indalls,inds] = sort(indall);
xalls = xall(inds);
yalls = yall(inds);

Hline = line('xdata',xalls,'ydata',yalls,'color','k','marker','o',...
    'linestyle','none','markersize',3,'tag','black');
set(gca,'ticklength',[0 0],'xticklabel','','yticklabel','')

% Really what we need is the handle to the axes. So, return Hline as the
% curent axes. 

Haxs = gca;












