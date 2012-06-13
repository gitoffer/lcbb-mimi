function angles = get_neighbor_angle(cx,cy,time)
%GET_NEIGHBOR_ANGLE
% Given the centroids of the focal cells and their neighbors, will return a
% NxN-array of the angles between the foci and neighbors.
%
% SYNOPSIS: angles = get_neighbor_angle(centroid_x,centroid_y, ...
%   cx_neighbor,cy_neighbor,focal_cellIDs,orientations);
%
% xies@mit March 2012

[~,num_cells] = size(cx);

angles = nan(num_cells);
for i = 1:num_cells
    for j = 1:num_cells
        focal_x = cx(:,i);
        focal_y = cy(:,i);
        neighbor_x = cx(:,j);
        neighbor_y = cy(:,j);
        
        theta = atan2(...
            bsxfun(@minus,neighbor_y,focal_y) , ...
            bsxfun(@minus,neighbor_x,focal_x) );
%         if nargin > 5
%             theta = bsxfun(@minus,theta,orientations(:,c));
%         end
        
        angles(i,j) = nanmean(theta(time,:));
    end
    
end

end