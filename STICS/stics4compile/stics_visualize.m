%SCRIPT to make STICS calculated vector fields into movies

%% STICS movie

% sticsLoadName = '~/Desktop/Mimi/Data/05-26-2011/SqhGFPGap43_Maximumintensityprojection_gauss1_ch1_wt16_wx16_dt1/stics_ch1_wt16_wx16_dt1';
sticsLoadName = io.sticsSaveName;
load(sticsLoadName);

F = stics_movie(imcropped,stics_opt,stics_img,200);
movie2avi(F,[io.sticsSaveName])

%% EDGE STICS movie
% Will save movie

load([io.folder 'Membranes--basic_2d--Centroid-x'])
x_vertex = cell2mat(data)./0.16;
load([io.folder 'Membranes--basic_2d--Centroid-y'])
y_vertex = cell2mat(data)./0.16;

F = plot_stics_cellvelocity(membranes,o,vector,200,x_vertex,y_vertex);

movie2avi(F,[io.save_name,'/stics_celltraj',io.file_suffix])

%% Get strain (probably shouldn't use yet, without good STICS statistics)

E = cell(numel(vector),1);
for t = 1:numel(vector)
    E{t} = calc_strain(stics_img{t});
end

plot_strain(E,imcrop,Xf,Yf,io);

%% Compute and plot divergence

opt = struct('scaling',1.5,'movie_size',256*3,'histogram','off');
F = stics_div(stics_img,stics_opt,Xf,Yf,opt);
movie2avi(F,[io.save_name,'/div',io.file_suffix],'compression','None')

%% Other analysis tools

plot_stics_dots(stics_img,imcropped,stics_opt,io,2,'XY');

%%
plot_xy_color(stics_img,imcropped,io,16*.2);