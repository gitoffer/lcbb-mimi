function angles = get_neighbor_angle(cx,cy,cx_neighb,cy_neighb,focal_cells,orientations)
%GET_NEIGHBOR_ANGLE
% Given the centroids of the focal cells and their neighbors, will return a
% cell-array of the angles between the foci and neighbors. Can use 0-padded
% neighbor arrays, as returned by neighbor_msmt.m.
%
% SYNOPSIS: angles = get_neighbor_angle(centroid_x,centroid_y, ...
%   cx_neighbor,cy_neighbor,focal_cellIDs,orientations);
%
% xies@mit March 2012

num_foci = numel(focal_cells);

angles = cell(1,num_foci);
for i = 1:num_foci
    
    c = focal_cells(i);
    focal_x = cx(:,c);
    focal_y = cy(:,c);
    neighbor_x = cx_neighb{c};
    neighbor_y = cy_neighb{c};
    
%     if any(~isnan(focal_x)) && numel(neighbor_x) > 1
%         num_neighbor = size(neighbor_x,2);
    
        theta = atan2(...
            bsxfun(@minus,neighbor_y,focal_y) , ...
            bsxfun(@minus,neighbor_x,focal_x) );
        if nargin > 5
            theta = bsxfun(@minus,theta,orientations(:,c));
        end
        
        angles{i} = nanmean(theta(1:30,:));
%     end

end


end