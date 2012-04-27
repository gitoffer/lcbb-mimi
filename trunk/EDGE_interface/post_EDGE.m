function output = post_EDGE(handle)

EDGEstack = handle.EDGEstack;
zslice = handle.z;

output_dir = handle.io.save_dir;
warning off,mkdir(output_dir);warning on;

% measurement_names = {EDGEstack.name};
areas = extract_msmt_data(EDGEstack,'area','on',zslice);
myosins = extract_msmt_data(EDGEstack,'myosin intensity','on',zslice);
centroids_x = extract_msmt_data(EDGEstack,'centroid-x','on',zslice);
centroids_y = extract_msmt_data(EDGEstack,'centroid-y','on',zslice);
neighborID = extract_msmt_data(EDGEstack,'identity of neighbors','off',zslice);
vertices_x = extract_msmt_data(EDGEstack,'vertex-x','off',zslice);
vertices_y = extract_msmt_data(EDGEstack,'vertex-y','off',zslice);
majors = extract_msmt_data(EDGEstack,'major axis','on',zslice);
minors = extract_msmt_data(EDGEstack,'minor axis','on',zslice);
orientations = extract_msmt_data(EDGEstack,'orientation','on',zslice);
anisotropies = extract_msmt_data(EDGEstack,'anisotropy-xy','on',zslice);
coronals_area = extract_msmt_data(EDGEstack,'corona area','on',zslice);

[num_frames,num_cells] = size(areas);
n_measurements = 0;

%% correlate myosins and constriction rate for whole embryo
if ~isempty(areas) && ~isempty(myosins)
    %smooth data
    areas_sm = smooth2a(areas,1,0);
    myosins_sm = smooth2a(squeeze(myosins),1,0);
    % take derivative d/dt
    areas_rate = -central_diff_multi(areas_sm,1:num_frames);
    myosins_rate = central_diff_multi(myosins_sm,1:num_frames);
    %gernerate myosins-constriction rate correlation
    wt = handle.myo_area_corr.wt;
    correlations = nanxcorr(myosins_rate,areas_rate,wt,1);
    
    mean_corr = nanmean(correlations);
    std_corr = nanstd(correlations);
    figure(1),clf;
    showsub(@imagesc,{[-wt wt],[1 num_cells], correlations},'Cross-correlation per cell','colorbar', ...
        @errorbar,{-wt:wt,mean_corr,std_corr},'Mean cross-correlation','axis on');
    
    mkdir([output_dir '/correlations/whole_embryo/']);
    saveas(gcf,[output_dir '/correlations/whole_embryo/myosinrate_constrictionrate'],'fig');
    
    output_h.myo_area_corr = 1;
    n_measurements = n_measurements + 1;
end

%% neighbor v. focus measurements
eval(['foc_meas =' handle.neighbor_focus.focal_measurement ';']);
foc_name = handle.neighbor_focus.focal_name;
eval(['neighb_meas =' handle.neighbor_focus.neighbor_measurement ';']);
neighb_name = handle.neighbor_focus.neighbor_name;
if ~isempty(foc_meas) && ~isempty(neighb_meas) && ~isempty(neighborID)
    [neighbor_meas,focal_cellIDs] = neighbor_msmt(neighb_meas,neighborID(1,:));
    num_foci = numel(focal_cellIDs);
    
    wt = handle.neighbor_focus.wt;
    dynamic_corr = cell(1,num_foci);
    avg_dynamic_corr = nan(num_cells,2*wt+1);
    std_dynamic_corr = nan(num_cells,2*wt+1);
    max_dynamic_corr = cell(1,num_foci);
    shift_dynamic_corr = cell(1,num_foci);
    
    % Get dynamic correlation
    for j = 1:num_foci
        cellID = focal_cellIDs(j);
        % get dynamic corr for all neighbors
        num_neighbors = numel(neighborID{1,cellID});
        this_corr = zeros(num_neighbors,2*wt+1);
        %     keyboard
        for i = 1:num_neighbors
            this_corr(i,:) = nanxcorr(foc_meas(:,cellID),neighbor_meas{cellID}(:,i),wt);
        end
        dynamic_corr{j} = this_corr;
        avg_dynamic_corr(cellID,:) = nanmean(this_corr,1);
        std_dynamic_corr(cellID,:) = nanstd(this_corr,1);
        [~,I] = nanmax(abs(this_corr),[],2);
        max_dynamic_corr{j} = this_corr(I)';
        shift_dynamic_corr{j} = I'-wt;
    end
    
    % Plot dynamic correlation
    figure(1),clf;
    [x,y] = meshgrid(-wt:wt,1:num_cells);
    pcolor(x,y,avg_dynamic_corr);colorbar,axis equal tight;
    title(['Dynamic correlation between neighbors''s ' neighb_name ' and center cell''s ' foc_name]);
    
    % Save dynamic cell-neighbor correlation
    mkdir([output_dir '/neighbor_focus/whole_embryo/']);
    saveas(gcf,[output_dir '/neighbor_focus/whole_embryo/' neighb_name '_' foc_name]);
    
    % Get pearson's correlation between cells & its neighbors
    handle.neighbor_focus.pearson.vertex_x = vertices_x;
    handle.neighbor_focus.pearson.vertex_y = vertices_y;
    handle.neighbor_focus.pearsons.savename = [output_dir '/neighbor_focus/cells/' neighb_name '_' foc_name '/cell_'];
    mkdir([output_dir '/neighbor_focus/cells/' neighb_name '_' foc_name '/']);
    
    pearsons = neighbor_cell_pearson(foc_meas,neighbor_meas,focal_cellIDs,neighborID,...
        handle.neighbor_focus.pearsons);
    
    % Get angle distribution
    fociIDs = 1:num_foci;
    eval(['angle_data = ' handle.neighbor_focus.neighbor_angles.angle_data ';']);
    centroid_x_neighbor = neighbor_msmt(centroids_x,neighborID(1,:));
    centroid_y_neighbor = neighbor_msmt(centroids_y,neighborID(1,:));
    
    angles = get_neighbor_angle(centroids_x,centroids_y, ...
        centroid_x_neighbor,centroid_y_neighbor,focal_cellIDs);
    angles_mat = cell2mat(angles(fociIDs))';
    angle_data = cell2mat(angle_data(fociIDs));
    angle_data = angle_data(:);
    
    figure(1);clf;
    polar(angles_mat(angle_data>0),angle_data(angle_data>0),'r*');
    hold on
    polar(angles_mat(angle_data<0),angle_data(angle_data<0),'b*');
    ylabel('Correlation')
    saveas(gcf,[output_dir '/neighbor_focus/whole_embryo/neighbor_angle_' neighb_name '_' foc_name]);
    
    y33 = quantile(angle_data,.33)
    y66 = quantile(angle_data,.66)
    theta_bins = handle.neighbor_focus.neighbor_angles.theta_bins;
    
    showsub( ...
        @rose,{angles_mat(angle_data>y66),theta_bins},'Top 66-quantile','ylabel(''Correlations'')', ...
        @rose,{angles_mat(angle_data<y33),theta_bins},'Bottom 33-quantile','', ...
        @rose,{angles_mat(angle_data>y33 & angle_data<y66),theta_bins},'33-66 quantile','', ...
        @rose,{angles_mat,theta_bins},'All cells','' ...
        );
    suptitle(['Neighbor angle distribution for correlations between foci''s ' foc_name ' and neighbor''s ' neighb_name])
    % Save movies
    saveas(gcf,[output_dir '/neighbor_focus/whole_embryo/neighbor_angle_' neighb_name '_' foc_name '_hist']);
    
    % Keep track for output
    output_h.neighbor = 1;
    n_measurements = n_measurements + 1;
end

%% ID pulses (gaussians)
if ~isempty(myosins)
    peaks = zeros(size(myosins_sm));
    opt = optimset('Display','off');
    for i = 1:num_cells
        myosin_sm = myosins_sm(:,i);
        if numel(myosin_sm(~isnan(myosin_sm))) > 1 && any(myosin_sm > 0)
            myosin_interp = interp_and_truncate_nan(myosin_sm);
            x = 1:numel(myosin_interp);
            myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
            lb = [0 0 0];
            ub = [Inf num_frames 20];
            gauss_p = iterative_gaussian_fit(myosin_nobg,x,0.1,lb,ub);
            left = max(fix(gauss_p(2,:)) - fix(gauss_p(3,:)),1);
            right = min(fix(gauss_p(2,:)) + fix(gauss_p(3,:)),num_frames);
            for j = 1:numel(left)
                peaks(left(j):right(j),i) = 1;
            end
        end
    end
    
    % Generate ROI
    roi_gauss = logical(peaks);
    input_gauss = myosins_rate; input_gauss(~roi_gauss) = NaN;
    response_gauss = areas_rate; response_gauss(~roi_gauss) = NaN;
    
    % Plot peak locations as pcolor image
    [x,y] = meshgrid(1:num_frames,1:num_cells);
    figure(1),clf
    pcolor(x,y,peaks');colorbar;
    title('Peak locations detected by Gaussian fits')
    xlabel('Time (frames');ylabel('Cells')
    mkdir([output_dir '/peak_gauss/']);
    saveas(gcf,[output_dir '/peak_gauss/peak_locations']);
    
    % Plot PDF and CDF of masked constriction rate
    figure(1),clf;
    plot_pdf(cat(2,areas_rate(:),response_gauss(:)),30);
    legend('Overall measured constriction rate',['Constriction rates masked by myosin peaks']),hold off;
    saveas(gcf,[output_dir '/peak_gauss/constriction_rate_pdf']);
    figure(1),clf;
    plot_cdf(cat(2,areas_rate(:),response_gauss(:)),30);
    legend('Overall measured constriction rate',['Constriction rates masked by myosin peaks']),hold off;
    saveas(gcf,[output_dir '/peak_gauss/constriction_rate_cdf']);
    
    figure(1),clf;
    plot_pdf(cat(2,myosins_rate(:),input_gauss(:)),30);
    legend('Overall measured myosin accumulation rate',['Myosin rate masked by myosin peaks']),hold off;
    saveas(gcf,[output_dir '/peak_gauss/myosin_pdf']);
    figure(1),clf;
    plot_cdf(cat(2,myosins_rate(:),input_gauss(:)),30);
    legend('Overall measured myosin accumulation rate',['Myosin rates masked by myosin peaks']),hold off;
    saveas(gcf,[output_dir '/peak_gauss/myosin_cdf']);
    
    if handle.peak_gauss.display
        % Make movies
        
        mkdir([output_dir '/peak_gauss/movies/'])
        % All responses
        h.todraw = 1:num_cells;
        h.m = response_gauss;
        h.title = 'Constriction rates masked by pulses';
        h.vertex_x = vertices_x;
        h.vertex_y = vertices_y;
        h.caxis = handle.peak_gauss.caxis;
        F = draw_measurement_on_cell_small(h);
        movie2avi(F,[output_dir '/peak_gauss/movies/all_constriction_rate_responses']);
        
        % All positive responses
        increasing = nan(size(response_gauss));
        increasing(response_gauss > 0) = response_gauss(response_gauss > 0);
        h.todraw = 1:num_cells;
        h.m = increasing;
        h.title = 'Constriction rates masked by pulses';
        h.vertex_x = vertices_x;
        h.vertex_y = vertices_y;
        h.caxis = handle.peak_gauss.caxis;
        F = draw_measurement_on_cell_small(h);
        movie2avi(F,[output_dir '/peak_gauss/movies/constricting_responses']);
        
        decreasing = nan(size(response_gauss));
        decreasing(response_gauss < 0) = response_gauss(response_gauss < 0);
        h.todraw = 1:num_cells;
        h.m = decreasing;
        h.title = 'Constriction rates masked by pulses';
        h.vertex_x = vertices_x;
        h.vertex_y = vertices_y;
        h.caxis = handle.peak_gauss.caxis;
        F = draw_measurement_on_cell_small(h);
        movie2avi(F,[output_dir '/peak_gauss/movies/constricting_responses']);
        
    end
    
    output_h.peak_gauss = 1;
    n_measurements = n_measurements + 1;
    
end

%% ID pulses (consecutive)
if ~isempty(myosins)
    
    count_threshold = handle.peak_consecutive.count_threshold;
    
    mkdir([output_dir '/peak_consecutive_' num2str(count_threshold) '/']);
    counts = find_consecutive_logical(myosins_rate > 0);
    
    % Segment out the section of increasing myosin that has at least
    % the given number of inreasing runs
    roi_consec = hysteresis_thresholding(counts,1,count_threshold,[1;1;1]);
    % Plot identified pulse locations
    figure(1),clf;
    imagesc(logical(roi_consec)'),xlabel('Time'),ylabel('Cells'),caxis([-5 5]),colorbar;
    title('Constriction rates masked by myosin increasing regions');
    saveas(gcf,[output_dir '/peak_consecutive_' num2str(count_threshold) '/peak_locations']);
    
    % Get INPUT and RESPONSE
    input_consec = myosins_rate; input_consec(~roi_consec) = NaN;
    response_consec = areas_rate; response_consec(~roi_consec) = NaN;
    
    % Plot PDF and CDF of masked constriction rate
    figure(1),clf;
    plot_pdf(cat(2,areas_rate(:),response_consec(:)),30);
    legend('Overall measured constriction rate',['Constriction rates masked by myosin increasing threhold ' num2str(count_threshold)]),hold off;
    saveas(gcf,[output_dir '/peak_consecutive_' num2str(count_threshold) '/constriction_rate_pdf']);
    figure(1),clf;
    plot_cdf(cat(2,areas_rate(:),response_consec(:)),30);
    legend('Overall measured constriction rate',['Constriction rates masked by myosin increasing threhold ' num2str(count_threshold)]),hold off;
    saveas(gcf,[output_dir '/peak_consecutive_' num2str(count_threshold) '/constriction_rate_cdf']);
    
    figure(1),clf;
    plot_pdf(cat(2,myosins_rate(:),input_consec(:)),30);
    legend('Overall measured myosin accumulation rate',['Myosin rate masked by myosin increasing threhold ' num2str(count_threshold)]),hold off;
    saveas(gcf,[output_dir '/peak_consecutive_' num2str(count_threshold) '/myosin_pdf']);
    figure(1),clf;
    plot_cdf(cat(2,myosins_rate(:),input_consec(:)),30);
    legend('Overall measured myosin accumulation rate',['Myosin rates masked by myosin increasing threhold ' num2str(count_threshold)]),hold off;
    saveas(gcf,[output_dir '/peak_consecutive_' num2str(count_threshold) '/myosin_cdf']);
    
    if handle.peak_consecutive.display
        % Make movies
        mkdir([output_dir '/peak_consecutive_' num2str(count_threshold) '/movies/'])
        
        % All responses
        h.todraw = 1:num_cells;
        h.m = response_consec;
        h.title = 'Constriction rates masked by pulses';
        h.vertex_x = vertices_x;
        h.vertex_y = vertices_y;
        h.caxis = handle.peak_consecutive.caxis;
        F = draw_measurement_on_cell_small(h);
        movie2avi(F,[output_dir '/peak_consecutive_' num2str(count_threshold) '/movies/all_constriction_rate_responses']);
        
        % All increasing (constricting) cells
        increasing = nan(size(response_consec));
        increasing(response_consec > 0) = response_consec(response_consec > 0);
        h.todraw = 1:num_cells;
        h.m = increasing;
        h.title = 'Constriction rates masked by pulses (all constricting)';
        h.vertex_x = vertices_x;
        h.vertex_y = vertices_y;
        h.caxis = handle.peak_consecutive.caxis;
        F = draw_measurement_on_cell_small(h);
        movie2avi(F,[output_dir '/peak_consecutive_' num2str(count_threshold) '/movies/constricting_responses']);
        
        % All decreasing (expanding) cells
        decreasing = nan(size(response_consec));
        decreasing(response_consec < 0) = response_consec(respose_consec < 0);
        h.todraw = 1:num_cells;
        h.m = decreasing;
        h.title = 'Constriction rates masked by pulses (all expanding)';
        h.vertex_x = vertices_x;
        h.vertex_y = vertices_y;
        h.caxis = handle.peak_consecutive.caxis;
        F = draw_measurement_on_cell_small(h);
        movie2avi(F,[output_dir '/peak_consecutive_' num2str(count_threshold) '/movies/expanding_responses']);
    end
    output_h.peak_consecutive = 1;
    
end

%% Output

first = 1;
if output_h.myo_area_corr
    this.name = 'myosin constriction rate correlation';
    this.data = correlations;
    if first
        output = this;
        first = 0;
    else
        output = [output this];
    end
end
if output_h.neighbor
    this.name = 'neighbor to focal cell angle data';
    this.data = angle_data;
    if first
        output = this;
        first = 0;
    else
        output = [output this];
    end
    this.name = 'neighbor to focal cell angles';
    this.data = angles_mat;
    output = [output this];
end
if output_h.peak_gauss
    this.name = 'myosin peaks detected by gaussian peaks';
    this.data = roi_gauss;
    if first
        output = this;
        first = 0;
    else
        output = [output this];
    end
    this.name = 'constriction rate masked by gaussian pulses';
    this.data = response_gauss;
    
end
if output_h.peak_consecutive
    this.name = 'myosin peaks detected by consecutive myosin increases';
    this.data = roi_consec;
    if first
        output = this;
        first = 0;
    else
        output = [output this];
    end
    this.name = 'constriction rate masked by gaussian pulses';
    this.data = response_consec;
    
end
varargout{1} = output;

end


