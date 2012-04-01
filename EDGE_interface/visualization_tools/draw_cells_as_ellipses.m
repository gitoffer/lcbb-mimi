function F = draw_cells_as_ellipses(handle)
%DRAW_CELLS_AS_ELLIPSES Draws cells roughly as fitted ellipses and colorize
%by XY measurementotropy.
%
% SYNOPSIS: draw_cells_as_ellipses(m,zID)
%
% INPUT: m - stack of EDGE measurements

% get handles
centroid_x = handle.x;
centroid_y = handle.y;
mino = handle.minor;
majo = handle.major;
orientation = handle.o;
measurement = handle.m;

% colorbar range
max_measurement = nanmax(measurement(:));
min_measurement = nanmin(measurement(:));

% cat data for easy handling.
data = cat(3,centroid_x,centroid_y,majo,mino,orientation,measurement);

[num_frames,num_cells,~] = size(data);

% Set figure size to always be 1/4 of screen
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
fig1 = figure;
position = get(fig1,'Position');
outerpos = get(fig1,'OuterPosition');
borders = outerpos - position;
edge = -borders(1)/2;
pos1 = [edge,scnsize(4)/2,scnsize(3)/2 - edge,scnsize(4)/2];
set(fig1,'OuterPosition',pos1)

% plot ellipses using ellipse.m (patch object)
for i = 1:num_frames
    clf
    this_frame = squeeze(data(i,:,:));
    color = zeros(num_cells,3);
    for j = 1:num_cells
        if ~any(isnan(this_frame(j,:)))    
            color(j,:) = find_color(this_frame(j,6),min_measurement,max_measurement);
        end
    end
        ellipse(this_frame(:,3),this_frame(:,4),this_frame(:,1),this_frame(:,2),this_frame(:,5),...
            color);
        hold on
        axis equal ij
        axis([20 180 0 80]);
%     end
    caxis([min_measurement max_measurement])
    colorbar
    drawnow;
    F(i) = getframe(gcf);
end


% % plot ellipses
% for i = 1:num_frames
%     clf
%     for j = 1:num_cells
%         this_frame = data(i,j,:);
%         if any(isnan(this_frame))
%             continue
%         else
%             color = find_color(this_frame(6),min_measurement,max_measurement);
%             ellipse(this_frame(3),this_frame(4),this_frame(1),this_frame(2),this_frame(5),...
%                 color);
%             hold on
%             axis equal ij
%             axis([20 180 0 80]);
%         end
%     end
%     caxis([min_measurement max_measurement])
%     colorbar
%     drawnow;
%     F(i) = getframe(gcf);
% end
