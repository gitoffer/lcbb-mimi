function imsequence_color(imsequence,savename)
%IMSEQUENCE_COLOR Uses SURFC to plot a image sequence. Will save to AVI
%file if a filename is also given.
%
% SYNOPSIS: imsequence_color(imseq,filename)
% INPUT: imseq - 3D array indexed by X,Y,T
%        savename - (optional) if provided, will save to this file as AVI
%
% Jun He @ mit.

num_frame = size(imsequence,3);
% max_pix_value = max(max(max(imsequence)));
% min_pix_value = min(min(min(imsequence)));
%%%set image play size

figure(102),clf;
if nargin > 1
    J(1:num_frame) = struct('cdata', [],...
        'colormap', []);
end

for j = 1:num_frame
    A= imsequence(:,:,j);
    surfc(A,'EdgeColor', 'none', 'FaceColor', 'flat');
    set(gcf, 'Renderer', 'zbuffer');
    axis equal;
    %axis normal;
    %axis tight;
    
    %set(gca, 'view', [-45 45]);
    set(gca, 'view', [0 90]);
    if nargin > 1
        F(j) = getframe;
    end
    drawnow;
end
if nargin > 1
    movie2avi(F,savename,'compression','none')
end

end
