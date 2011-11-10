function plot_xy_color(vector,o,io,scale)
% Plots X and Y components of the STICS vectors

n = length(vector);
color_lim = [-.05 0.05];
handle = figure(200);

[y x foo] = size(o.im);

clear M;
clf;

for i=1:n
    
    v = vector{i};
    xComp = imresize(v(:,:,1),scale);
    yComp = imresize(v(:,:,2),scale);
    
    h = subplot(2,1,1);
    set(gcf,'Position',[500 200 x+200 y+200])
    pcolor(xComp);
    axis([1 x 1 y])
    axis equal

    shading flat
    title('X components');
    caxis('manual');
    caxis(color_lim);
    colorbar;
    
    subplot(2,1,2);
    set(gcf,'Position',[500 200 x+200 y+200])
    pcolor(yComp);
    axis([1 x 1 y])
    axis equal

    shading flat
    title('Y components');
    caxis('manual');
    caxis(color_lim);
    colorbar;
    drawnow;
    
    M(i) = getframe(handle);
end
movie(M);
movie2avi(M,[io.save_name,'/XYcolor',io.file_suffix]);
