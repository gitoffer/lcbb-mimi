function plot_stics_dots(vector,o,io,window,varargin)

[Xf Yf] = grid4stics(o.im, o.dx, o.dy, o.wx, o.wy);

if isempty(varargin)
    direction = 'XY';
else
    direction = varargin{1};
end

if strcmpi(direction,'t')
    stics_dots = getDotsTemporal(vector,window);
else
    stics_dots = getDots4Stics(vector,window,direction);
end

clear M

n = length(vector);

scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)/3 scrsz(3)/3 scrsz(4)/3]);

for i = 1:n    
    pcolor(Xf,Yf,stics_dots(:,:,i))
    caxis([-1 1])
    colorbar;
    
    axis equal, axis tight;
    title([direction ' coherence (window ' num2str(window) ')']);
    drawnow;
    M(i)=getframe(gcf);
end
movie2avi(M,[io.save_name,'/stics_dots',direction,io.file_suffix,'_window',int2str(window)]);