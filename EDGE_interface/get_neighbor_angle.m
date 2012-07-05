function angles = get_neighbor_angle(cx,cy,tref)
%GET_NEIGHBOR_ANGLE
% Given the centroids of all cells, will return NxN-array of the angles between all 
% pairs of cells, for a given reference time (e.g. tref = 1, default);
%
% SYNOPSIS: angles = get_neighbor_angle(centroid_x,centroid_y,tref);
%
% xies@mit March 2012

if nargin < 3, tref = 1; end

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
        
        angles(i,j) = nanmean(theta(tref,:));
    end
    
end

end
