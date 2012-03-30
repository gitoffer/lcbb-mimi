
%% Generate correlations

areas_sm = smooth2a(squeeze(areas(:,zslice,:)),1,0);
myosin_sm = smooth2a(squeeze(myosins(:,zslice,:)),1,0);
major = squeeze(majors(:,zslice,:));
minor = squeeze(minors(:,zslice,:));
orientation = squeeze(orientations(:,zslice,:));
anisotropy = squeeze(anisotropies(:,zslice,:));

areas_rate = -central_diff_multi(areas_sm,1,1);

%%

strain_rate = nan(2,2,num_frames-1,num_cells);
strain_maj = nan(num_frames,num_cells);
strain_min = nan(num_frames,num_cells);
strain_thetas = nan(num_frames,num_cells);
fval = nan(num_frames,num_cells);

for cellID = 1:82
    for i = 1:num_frames-1
        lx = ellipse_x(i,cellID); ly = ellipse_y(i,cellID);
        dtlx = ellipse_x(i+1,cellID); dtly = ellipse_y(i+1,cellID);
        % check for NaN
        if ~isnan(lx) && ~isnan(ly) && ~isnan(dtlx) && ~isnan(dtly) ...
                && ~isnan(areas_rate(i,cellID))
            
            % Get ellipse shape
            shape_0 = get_ellipse(0,0,lx,ly,deg2rad(orientation(i,cellID)))';
            shape_f = get_ellipse(0,0,dtlx,dtly,deg2rad(orientation(i+1,cellID)))';
            
            % Get strain rate; diagonalize
            [def,val,flag] = get_cell_strain_rate(...
                shape_0,shape_f, ...
                log(areas_sm(i,cellID)./areas_sm(i+1,cellID)/2));
            
            if flag > 0
                fval(i,cellID) = val;
                e = symmpart(def);
                [vects,lambdas] = eigs(e,2);
                
                % collect everything into appropriate ellipse-plotting
                % variables
                strain_rate(:,:,i,cellID) = e;
                strain_maj(i,cellID) = lambdas(1,1);
                strain_min(i,cellID) = lambdas(2,2);
                strain_thetas(i,cellID) = atan2(vects(2,1),vects(1,1));
            end
        end
    end
end

%%

cellIDs = 1:82;

handle.x = extract_msmt_data(m,'centroid-x','on',zslice);
handle.y = extract_msmt_data(m,'centroid-y','on',zslice);
handle.m = myosin_sm;
handle.major = major;
handle.minor = minor;
handle.o = deg2rad(orientation);
handle.vertex_x = vx; handle.vertex_y = vy;

F = draw_cells_as_lines(handle);
movie2avi(F,'~/Desktop/cell_shape_myosincolor.avi')

