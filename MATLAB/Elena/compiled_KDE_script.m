embryoID = 3;

kernel_width = 3; %h-value

area_binSize = .1; % microns^2
edges = nanmin(areas(:)) : area_binSize : nanmax(areas(:));
dt = 70; %seconds
min_time = nanmin( dev_time(embryoID,:) );
max_time = nanmax( dev_time(embryoID,:) );
numOfGraphs = floor( (max_time - min_time)/dt );

for i = 1:numOfGraphs
    
    % find the time-interval of interest
    interval = [min_time + dt*(i-1), min(min_time + dt*i, max_time) ]; 
    % find the frames corresponding to interval
    frames_within_interval = ...
        dev_time(embryoID,:) > interval(1) & dev_time(embryoID,:) <= interval(2);
    % extract relevant area time-subseries
    area_time_binned = areas( frames_within_interval, [IDs.which] == embryoID);
%     keyboard
    % cosntruct KDE
    kde_value =gaussian_KDE( ...
        area_time_binned, kernel_width, edges, 0); % h = 1, first derivative = 1 , xrange is 1 to 100 
    
    % generate subplots
    subplot(numOfGraphs, 1, i)
    
    plot(edges, kde_value), xlabel('Area');
    xlabel('Area (\mum^2)');
    ylabel(['Frequency ']);
    title([num2str(1+(tint *(i-1))) 's to ' num2str(i*tint) 's']);
    
end
