function F = draw_measurement_on_cells_patch(handle)
%DRAW_MEAUSREMENT_ON_CELL_SMALL Color-in a measurement on a small subset of
%cells using patch objects and cell vertices.
%
% SYNOPSIS: draw_measurement_on_cell_small(handle)
%
% INPUT: handle - a struture of relevant measurements. required fields:
%               vertex_x - x vertices to draw
%               vertex_y - y vertices to draw
%               m - measurement to color cells with
% (optional)    todraw - specify cell indices to color, and leave other
%                        cells white/blank
%
% See also: DRAW_MEASUREMENT_ON_CELLS
% 
% xies@mit.edu. March 2012.

% get relevant data
measurement = handle.m;
vertices_x = squeeze(handle.vertex_x);
vertices_y = squeeze(handle.vertex_y);
num_frames = size(measurement,1);
num_cells = size(vertices_x,2);

if ~isfield(handle,'todraw')
    cells_to_draw = 1:num_cells;
else
    cells_to_draw = handle.todraw;
end

% colorbar range
if ~isfield(handle,'caxis')
    max_measurement = nanmax(measurement(:));
    min_measurement = nanmin(measurement(:));
else
    min_measurement = handle.caxis(1);
    max_measurement = handle.caxis(2);
end

% Sets the movie size to be 1/4 of screen.
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
fig1 = figure(1);
position = get(fig1,'Position');
outerpos = get(fig1,'OuterPosition');
borders = outerpos - position;
edge = -borders(1)/2;
pos1 = [edge, scnsize(4)/2, scnsize(3)/2 - edge, scnsize(4)/2];
set(fig1,'OuterPosition',pos1)
axis fill

% Preallocate movie
F(1:num_frames) = struct('cdata', [],...
    'colormap', []);

% plot cells as polygon using patch object
for i = 1:num_frames
    clf
    for j = 1:num_cells
        if any(isnan(vertices_x{i,j}))
            continue
        else
            
            % get color according to measurement range
            if any(j == cells_to_draw) && ...
                    ~isnan(measurement(i,find(cells_to_draw == j)))
%                 color = find_color(measurement(i,find(cells_to_draw == j)),min_measurement,max_measurement,...
%                     256,@jet);
                switch measurement(i,find(cells_to_draw == j))
                    case 1
                        color = [0 0 1];
                    case 2
                        color = [0 153 255]/255;
                    case 3
                        color = [0 102 0]/255;
                    case 4
                        color = [1 0 1];
                    case 5
                        color = [1 0 0];
                    otherwise
                        color = [1 1 1];
                end
                        
            else
                color = [1 1 1];
            end
            
            % Draw cell boundary if specified
            vert_x = vertices_x{i,j}; vert_y = vertices_y{i,j};
            obj = patch(vert_x,vert_y,color);
            %             alpha(obj,.5);
            
            hold on
            axis equal ij fill
            axis([100 900 0 400]);
%             axis off
        end
    end
    title(handle.title)
    caxis([min_measurement max_measurement])
%     colorbar
    drawnow;
    F(i) = getframe(gcf);
end

end
