
%% STICS movie

% sticsLoadName = '~/Desktop/Mimi/Data/05-26-2011/SqhGFPGap43_Maximumintensityprojection_gauss1_ch1_wt16_wx16_dt1/stics_ch1_wt16_wx16_dt1';
sticsLoadName = io.sticsSaveName;
load(sticsLoadName);

F = stics_movie(imcropped,o,stics_img,200);
movie2avi(F,[io.sticsSaveName])

%% EDGE STICS movie

load([io.folder 'Membranes--basic_2d--Centroid-x'])
x_vertex = cell2mat(data)./0.16;
load([io.folder 'Membranes--basic_2d--Centroid-y'])
y_vertex = cell2mat(data)./0.16;

F = plot_stics_cellvelocity(membranes,o,vector,200,x_vertex,y_vertex);

movie2avi(F,[io.save_name,'/stics_celltraj',io.file_suffix])

%% Get strain

E = cell(numel(vector),1);
for t = 1:numel(vector)
    E{t} = calc_strain(vector{t});
end

plot_strain(E,imcrop,Xf,Yf,io);

%% compute and plot divergence

clear mex F
movie_size = 256*3;
EF = 1; % expand_factor
figure(10000)

for j = 1:t(end)+floor(wt/2)
    div(:,:,j) = divergence(Xf,Yf,velocity(:,:,1,j), velocity(:,:,2,j));
end
clear j

for j = 1:t(end)+floor(wt/2)
    surf(imresize(div(:,:,j),EF))
    
    axis equal
    axis([1, size(div(:,:,1,1),2)*EF, 1, EF*size(div(:,:,1,1),1)]);
    set(gca,'clim',[min(div(:)),  max(div(:))])
    set(gca,'YDir','normal')
    colorbar;
    title(['Divergence map for frame', num2str(j), ' wt:',int2str(o.wt),' wx:',int2str(o.wx),' dt:',int2str(o.dt)]);
    
    shading interp
    set(gcf, 'renderer','zbuffer')
    view([0 -90])
    %     set(gca, 'units', 'pixels', 'Position', [100 0 movie_size/2 movie_size]);
    set(gcf, 'units', 'pixels', 'Position', [250 250 movie_size-100 movie_size+10]);
    
    % % % putting scale bar
    % scalebar = 4; %scalebar length in um
    % offest = [0.05 0.05]; % text postion offest from scale bar
    % percent_len = scalebar/(size(div,2)*dx*o.um_per_px); %scalebar percentage length
    % line([size(div,2)*EF*(0.97-percent_len),size(div,2)*EF*0.97],[size(div,1)*EF*0.97,size(div,1)*EF*0.97],[-max(div(:)) -max(div(:))],'color','b','linewidth',5)
    % text(size(div,2)*EF*(0.97-percent_len+offest(1)),size(div,2)*EF*(0.97-offest(2)), -max(div(:)), [num2str(scalebar),' \mum'],'color','b')
    
    F(j) = getframe(gcf);
end
movie(F)
movie2avi(F,[io.save_name,'/div',io.file_suffix],'compression','None')

figure(2000)
hist(div(:),100)
xlabel('div of velocity (min^{-1})')
ylabel('counts')
title('for all frames')

title({'Div for all frames',...
    ['Mean = ',num2str(mean2(div(:)),'%10.4f'),'min^{-1}'],...
    ['St. Dev. = ',num2str(std(div(:)),'%10.4f'),'min^{-1}']})

%% Other analysis tools

plot_stics_dots(vector,o,io,2,'XY');
plot_xy_color(vector,o,io,5);