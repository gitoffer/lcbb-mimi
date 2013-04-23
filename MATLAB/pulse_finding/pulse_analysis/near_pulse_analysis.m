

num_fits = numel( fits_wt );

time_windows = 1:5:60; %seconds
% nearby = cell( 6,num_fits );
% nearID = cell( 6 , num_fits);

num_near = zeros(12,num_fits);
% 
for j = 1:12
    time_window = time_windows(j);
    
    fits = fits_wt.find_near_fits(time_window, neighborID);
%     nearby{i} = near;
    num_near(j,:) = cellfun( @numel, IDs );
    
end


%%

scatter( [fits_wt.center], num_near(10,:) );

%%
N = hist( num_near' , 0:max(num_near(:)) );

bar( 0:max(num_near(:)), N, 'group');

figure

N = hist( num_near(:)' , 0:max(num_near(:)) );

bar( 0:max(num_near(:)), N, 'group');

