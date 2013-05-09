
num_fits = numel( fits_wt );

time_windows = 1:5:60; %seconds
% nearby = cell( 6,num_fits );
% nearID = cell( 6 , num_fits);

fits_wt = fits_wt.find_near_fits(time_windows, neighborID);

%%

num_near =  {fits_wt.nearIDs(1,:)};

%%

scatter( [fits_wt.center], num_near(10,:) );

%%
N = hist( num_near' , 0:max(num_near(:)) );

bar( 0:max(num_near(:)), N, 'group');

figure

N = hist( num_near(:)' , 0:max(num_near(:)) );

bar( 0:max(num_near(:)), N, 'group');

