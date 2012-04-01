function F = draw_cells_as_lines(handle)
%DRAW_CELLS_AS_ELLIPSES Draws cells roughly as fitted ellipses and colorize
%by XY measurementotropy.
%
% SYNOPSIS: draw_cells_as_ellipses(m,zID)
%
% INPUT: m - stack of EDGE measurements

% get handles
centroid_x = handle.x;
centroid_y = handle.y;
majo = handle.major;
mino = handle.minor;
orientation = handle.o;
measurement = handle.m;
if isfield(handle,'vertex_x'),
    drawcell = 1;
    vertices_x = handle.vertex_x;
    vertices_y = handle.vertex_y;
end

% colorbar range
max_measurement = nanmax(measurement(:));
min_measurement = nanmin(measurement(:));

% cat data for easy handling.
% data = cat(3,centroid_x,centroid_y,lx,ly,orientation,measurement);

[num_frames,num_cells] = size(centroid_x);

set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
fig1 = figure;
position = get(fig1,'Position');
outerpos = get(fig1,'OuterPosition');
borders = outerpos - position;
edge = -borders(1)/2;
pos1 = [edge,...
    scnsize(4)/2,...
    scnsize(3)/2 - edge,...
    scnsize(4)/2];
set(fig1,'OuterPosition',pos1)

% for i = 1:num_frames
%     clf
%     x = centroid_x(:,i); y = centroid_y(:,i);
%     major = majo(:,i)/2; minor = mino(:,i)/2;
%     theta = orientation(:,i);
%     ms = measurement(:,i);
%
%     color = zeros(num_cells,3);
%     for j = 1:num_cells
%         if ~any(isnan(centroid_x(j)))
%             color(j,:) = find_color(measurement,min_measurement,max_measurement);
%         end
%     end
%     h = line([x - cos(theta).*major,x + cos(theta).*major], [y - sin(theta).*major,y + sin(theta).*major ],'Color',color);
% %     set(h,'Color',color);
%     % plot minor axis
%     h = line([x - sin(theta).*minor,x + sin(theta).*minor], [y + cos(theta).*minor,y - cos(theta).*minor ],'Color',color);
% %     set(h,'Color',color);
%     hold on
%     axis equal ij
%     axis([20 180 0 80]);
%     %     end
%     caxis([min_measurement max_measurement])
%     colorbar
%     drawnow;
%     F(i) = getframe(gcf);
% end

% plot ellipses
for i = 1:num_frames
    clf
    for j = 1:num_cells
        %         this_cell = data(i,j,:);
        if any(isnan(centroid_x(i,j)))
            continue
        else
            
            x = centroid_x(i,j); y = centroid_y(i,j);
            major = majo(i,j)/2; minor = mino(i,j)/2;
            theta = orientation(i,j);
            
            % get color
            color = find_color(measurement(i,j),min_measurement,max_measurement);
            
            % Draw cell boundary if specified
            if drawcell
                vert_x = vertices_x{i,j}; vert_y = vertices_y{i,j};
                patch(vert_x,vert_y,color,'FaceAlpha',0.3);
                
            end
            
            % plot major axis
            if theta >= 0
                h = line([x - cos(theta)*major,x + cos(theta)*major], [y - sin(theta)*major,y + sin(theta)*major ]);
                set(h,'Color',strain_rate_lut(major),'LineWidth',2);
                % plot minor axis
                h = line([x - sin(theta)*minor,x + sin(theta)*minor], [y + cos(theta)*minor,y - cos(theta)*minor ]);
                set(h,'Color',strain_rate_lut(minor),'LineWidth',2);
            else
                h = line([x - sin(theta)*major,x + sin(theta)*major], [y + cos(theta)*major,y - cos(theta)*major ]);
                set(h,'Color',strain_rate_lut(major),'LineWidth',2);
                % plot minor axis
                h = line([x - cos(theta)*minor,x + cos(theta)*minor], [y - sin(theta)*minor,y + sin(theta)*minor ]);
                set(h,'Color',strain_rate_lut(minor),'LineWidth',2);
            end
            
            hold on
            axis equal ij
            axis([20 180 0 80]);
        end
    end
    caxis([min_measurement max_measurement])
    colorbar
    drawnow;
    F(i) = getframe(gcf);
end
end

function color = strain_rate_lut(rate)
if isnan(rate)
    color = [0 0 0];
else
    if rate > 0, color = [0 0 1]; else color = [1 0 0]; end
end
end