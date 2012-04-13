function cellIDs = select_cells(cent_x,cent_y,Xedges,Yedges,frame)
%SELECT_CELLS Given cell centroids and the coordinates of a rectangular
% ROI, selects the cells whose centroids are within that window. By
% default only look at frame 1.
%
% SYNOPSIS: cellIDs = select_cells(centroid_x,centroid_y,Xedges,Yedges);
% INPUT: centroids_x - matrix of cell centroids' x-coordinates
%        centroids_y - matrix of cell centroids' y-coordinates
%        Xedges - [left right]
%        Yedges - [top bottom]
% OUTPUT: cellIDs - the cell numbers within the ROI
%
% xies@mit. March 2012.

% [~,num_cells] = size(cent_x);

if nargin < 5, frame = 1;end
% pull out frame of interest
cent_x = cent_x(frame,:);
cent_y = cent_y(frame,:);

% filter cellIDs
cellID_x = find(cent_x >= Xedges(1) & cent_x <= Xedges(2));
cellID_y = find(cent_y >= Yedges(1) & cent_y <= Yedges(2));
cellIDs = intersect(cellID_x,cellID_y);

end