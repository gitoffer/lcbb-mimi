%SCRIPT to make STICS calculated vector fields into movies

%% STICS movie

% sticsLoadName = '~/Desktop/Mimi/Data/05-26-2011/SqhGFPGap43_Maximumintensityprojection_gauss1_ch1_wt16_wx16_dt1/stics_ch1_wt16_wx16_dt1';
sticsLoadName = io.sticsSaveName;
load(sticsLoadName);

F = stics_movie(imcropped,stics_opt,stics_img,200);
movie2avi(F,[io.sticsSaveName])

%% Plot vectors as time series
crop = struct('x0',1,'xf',601,'y0',1,'yf',66); % CROP information
[stics_cropped,Xfc,Yfc] = stics_crop(stics_img,Xf,Yf,crop);

[N,M,~] = size(stics_cropped{1});
T = numel(stics_cropped);
V = zeros([N,M,2,T]);
for i = 1:numel(stics_cropped)
    V(:,:,:,i) = stics_cropped{i};
end

Vx = reshape(V(:,:,1,:),T,N*M);
Vy = reshape(V(:,:,2,:),T,N*M);
plot(Vx,'Linewidth',1),ylim([-.05,.05]); title('V_x')
figure,plot(Vy,'Linewidth',1); title('V_y')

%% Use edge to crop out cell
m = load_edge_data([io.folder 'Edge_export']);
[F,stics_cells] = stics_draw_cells(imcropped,stics_img,m,stics_opt,200);
movie2avi(F,[io.save_name,'/edge_stisc',io.file_suffix]);

%% Get strain (probably shouldn't use yet, without good STICS statistics)

E = cell(numel(stics_img),1);
for t = 1:numel(stics_img)
    E{t} = calc_strain(stics_img{t});
end
plot_strain(E,imcropped,Xf,Yf,io);

%% Compute and plot divergence

opt = struct('scaling',1.5,'movie_size',256*3,'histogram','off');
F = stics_div(stics_img,stics_opt,Xf,Yf,opt);
movie2avi(F,[io.save_name,'/div',io.file_suffix],'compression','None')

%% Other analysis tools

plot_stics_dots(stics_img,imcropped,stics_opt,io,2,'XY');

%%
plot_xy_color(stics_img,imcropped,io,16*.2);

%% EDGE STICS movie
% Will save movie

load([io.folder 'Membranes--basic_2d--Centroid-x'])
x_vertex = cell2mat(data)./0.16;
load([io.folder 'Membranes--basic_2d--Centroid-y'])
y_vertex = cell2mat(data)./0.16;

F = plot_stics_cellvelocity(membranes,o,vector,200,x_vertex,y_vertex);

movie2avi(F,[io.save_name,'/stics_celltraj',io.file_suffix])
