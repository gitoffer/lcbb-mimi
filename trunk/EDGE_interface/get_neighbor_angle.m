function angles = get_neighbor_angle(cx,cy,cx_neighb,cy_neighb)

num_cells = size(cx,2);

angles = cell(1,num_cells);
for c = 1:num_cells
    
    focal_x = cx(:,c);
    focal_y = cy(:,c);
    
    nonnans = ~isnan(focal_x);
    
    neighbor_x = cx_neighb{c};
    neighbor_y = cy_neighb{c};
    
    theta = atan2(neighbor_y,neighbor_x);
	
    angles{c}
end

