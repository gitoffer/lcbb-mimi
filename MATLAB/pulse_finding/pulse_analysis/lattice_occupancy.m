function R = lattice_occupancy(cells)
%LATTICE_OCCUPANCY


N = numel(cells);
T = size( cells(1).area,1);

R = cell(N,T);

for i = 1:N
    for t = 1:T
        
        this_cell = cells(i);
%         dframe = fix( timewindow/nanmean(diff(this_cell.dev_time)) );
        
        if ~isnan(this_cell.dev_time(t))
            
            same_embryo = cells.get_embryoID( this_cell.embryoID );
            % not the same cell (self)
            same_embryo = same_embryo( [same_embryo.cellID] ~= this_cell.cellID);
            
            cx = this_cell.centroid_x(t);
            cy = this_cell.centroid_y(t);
            
            nx = cat(2,same_embryo.centroid_x);
            ny = cat(2,same_embryo.centroid_y);
            nx = nx( t,: );
            ny = ny( t,: );
            
            lx = nx - cx;
            ly = ny - cy;
            
            foo = sqrt( lx.^2 + ly.^2 );
            R{i,t} = cat(1, 0, foo(:));
            
        end
        
    end
    display(['Done with cell #' num2str(i)]);
end