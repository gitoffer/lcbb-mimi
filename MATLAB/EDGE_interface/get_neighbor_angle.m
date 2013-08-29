function angles = get_neighbor_angle(cx,cy)
%GET_NEIGHBOR_ANGLE
% Given the centroids of all cells, will return NxN-array of the angles between all
% pairs of cells, for a given reference time (e.g. tref = 1, default);
%
% SYNOPSIS: angles = get_neighbor_angle(centroid_x,centroid_y,tref);
%
% xies@mit March 2012

% [~,num_cells] = size(cx);

[T,N] = size(cx);

angles = nan(T,N,N);
for t = 1:T
    
    for i = 1:N
        
        focal_x = cx(t,i);
        focal_y = cy(t,i);
        
        neighbor_x = cx(t,:);
        neighbor_y = cy(t,:);
        
        angles(t,i,:) = atan2(...
            bsxfun(@minus,neighbor_y,focal_y) , ...
            bsxfun(@minus,neighbor_x,focal_x) );
        
    end
    
end
