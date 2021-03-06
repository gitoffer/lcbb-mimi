function imsequence_color(imsequence,savename,movie_title,color_limits)
%IMSEQUENCE_COLOR Uses SURFC to plot a image sequence. Will save to AVI
%file if a filename is also given.
%
% SYNOPSIS: imsequence_color(imseq,filename)
% INPUT: imseq - 3D array indexed by X,Y,T
%        savename - (optional) if provided, will save to this file as AVI
%        movie_title - (optional)
%
% Jun He @ mit.

close all;
num_frame = size(imsequence,3);
if nargin < 4
    max_pix_value = nanmax(imsequence(:))/2;
    min_pix_value = nanmin(imsequence(:))/2;
    color_limits = [min_pix_value max_pix_value];
end
%%%set image play size to be 1/4 of screen
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
fig1 = figure(102);
position = get(fig1,'Position');
outerpos = get(fig1,'OuterPosition');
borders = outerpos - position;
edge = -borders(1)/2;
pos1 = [edge, scnsize(4)/2, scnsize(3)/2 - edge, scnsize(4)/2];
set(fig1,'OuterPosition',pos1)


clf;
if nargin > 1
    F(1:num_frame) = struct('cdata', [],...
        'colormap', []);
end

for j = 1:num_frame
    A = imsequence(:,:,j);
    if ~any(~isnan(A(:)))
        A = zeros(size(A));
    else
        %         surfc(A,'EdgeColor', 'none', 'FaceColor', 'flat');
        pcolor(A);
        shading flat
        set(gcf, 'Renderer', 'zbuffer');
        colormap(spring)
        caxis(color_limits);
        axis equal;
%         colorbar;
        %axis normal;
        axis xy off;
        if nargin > 2
            title(movie_title);
        end
        
        %set(gca, 'view', [-45 45]);
        %         set(gca, 'view', [0 90]);
    end
    if nargin > 1
        F(j) = getframe(gcf);
    end
    drawnow;
end

if nargin > 1
    movie2avi(F,savename,'compression','none')
end

end