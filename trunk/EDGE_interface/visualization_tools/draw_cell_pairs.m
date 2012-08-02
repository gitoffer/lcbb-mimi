function F = draw_cell_pairs(vx,vy,cx,cy,colors)
%DRAW_CELL_PAIRS Makes a movie of an embryo given the vertices, the
%centroids, and a relating variable between next-neighbor cells in the
%embryo.
%
% SYNOPSIS: F = draw_cell_pairs(vx,vy,cx,cy,pair_colors);
% INPUT: vx,vy - the coordinates of the veritices of the cells
%        cx,cy - the coordinates of the centroids
%        pair_colors - the relating variable betweeen pairs (N x N) where N
%        is the number of cells.
%
% xies@mit.edu Aug 2012

[num_frames,num_cells] = size(cx);

% Set movie to 1/4 of screen
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

F(1:num_frames) = struct('cdata', [],...
    'colormap', []);

for t = 1:num_frames
    clf
    
    for i = 1:num_cells
        hold on
        patch(vx{t,i},vy{t,i},[1 1 1]);
        for j = 1:num_cells
            if ~isnan(colors(i,j))
                h = line([cx(t,i) cx(t,j)],[cy(t,i) cy(t,j)]);
                color = find_color(colors(i,j),-1,1);
                set(h,'Color',color);
            end
        end
        axis equal ij fill
        axis([0 180 0 80]);
        axis off
    end
    caxis([-1 1]);
    colorbar;
    drawnow;
    F(t) = getframe(gcf);
    hold off
    
end

end

