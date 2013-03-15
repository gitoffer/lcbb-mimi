

num_fits = numel( fits );

time_windows = 1:11; %seconds
% nearby = cell( 6,num_fits );
% nearID = cell( 6 , num_fits);

num_near = zeros(10,num_peaks);
% 
for j = 1:10
    time_window = time_windows(j);
    
    [nearby_fits, IDs] = fits.find_near_fits(time_window, neighborID);
%     nearby{i} = near;
    num_near(j,:) = cellfun( @numel, IDs );
    
end


%%

scatter( [fits([fits.embryoID] < 6).center], num_near(6,[fits.embryoID] < 6) );


%%
N = hist( num_near(:, [fits.embryoID] < 6 )' , 0:max(num_near(:)) );

bar( 0:max(num_near(:)), N, 'group');

figure

N = hist( num_near(:, [fits.embryoID] >= 6 )' , 0:max(num_near(:)) );

bar( 0:max(num_near(:)), N, 'group');