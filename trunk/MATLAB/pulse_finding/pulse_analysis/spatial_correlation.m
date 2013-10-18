function [R] = spatial_correlation(centroid_x,centroid_y,fits,timewindow)
%SPATIAL_CORRELATION Find the spatial correlation amongst the location of
% pulse patterns.
%
% USAGE: R = spatial_correlation(centroid_x,centroid_y,fits,time_window)
% 
% INPUT: centroid_x, centroid_y - centroids of cell
% 		 
%
% xies@mit.edu

Nfits = numel(fits);

R = cell(1,Nfits);

for i = 1:Nfits
    
    % extract center fit
    this_fit = fits(i);
    fits_same_embryo = fits.get_embryoID( this_fit.embryoID );
    cx = centroid_x( fix(mean(this_fit.width_frames)), this_fit.stackID );
    cy = centroid_y( fix(mean(this_fit.width_frames)), this_fit.stackID );
    
    % get other fits within time window
    within_timewindow = ...
        fits_same_embryo( ...
        abs([fits_same_embryo.center] - this_fit.center) < timewindow & ... % within time window
        [fits_same_embryo.center] - this_fit.center >= 0 & ...          % occurs after center
        [fits_same_embryo.stackID] ~= this_fit.stackID ... 				% not the same cell
    );

    frames = fix(cellfun(@mean,{within_timewindow.margin_frames}));
    stackIDs = [within_timewindow.stackID];
    
    lx = zeros(1,numel(frames)); ly = zeros(1,numel(frames));
    for j = 1:numel(frames)
        lx(j) = centroid_x( frames(j),stackIDs(j) ) - cx;
        ly(j) = centroid_y( frames(j),stackIDs(j) ) - cy;
    end
    R{i} = [0 sqrt( lx.^2 + ly.^2 )];
    
end

end
