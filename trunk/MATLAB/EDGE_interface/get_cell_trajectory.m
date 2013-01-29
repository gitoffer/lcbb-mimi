function [centroid_x,centroid_y] = get_cell_trajectory(m,sliceID,frames,disp)
%GET_CELL_TRAJECTORY (from EDGE) Can use to display cell trajectories.
% NOTE: Not super useful... Only useful as a plotting tool.
%
% SYNOPSIS: [X,Y] = get_cell_trajectory(m,sliceID,frames)
%
% Outputs are optional.
% xies@mit. Dec 2012.

if ~exist('disp','var'), disp = 'off'; end

[centroid_x(:,:,:),u] = extract_msmt_data(m,'centroid-x');
centroid_y(:,:,:) = extract_msmt_data(m,'centroid-y');

% if ~exist('sliceID','var'), sliceID = 1; end

centroid_x = centroid_x(frames,sliceID,:);
centroid_y = centroid_y(frames,sliceID,:);

num_cells = size(centroid_x,2);
centroid_x = squeeze(centroid_x);
centroid_y = squeeze(centroid_y);

if strcmpi(disp,'on')
    cc = jet(num_cells);
    cc = cc(randperm(num_cells),:);
    for i = 1:num_cells
        this_track = cat(2,centroid_x(:,i),centroid_y(:,i));
        
        plot(this_track(:,1),this_track(:,2),'color',cc(i,:),'linewidth',2)
        plot(this_track(end,1),this_track(end,2),'s','markerfacecolor',cc(i,:))
        hold on
        
    end
    hold off
    xlabel(['Position in x (' u ')']);
    ylabel(['Position in y (' u ')']);
end

end