%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STICS - legacy, unmaintained                                            %
% Author: Jun He                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

DEBUG = 0;

%%%%%%%%%%%%%%%%%% Run Configuration file %%%%%%%%%%%
p = pwd;
cd('~/Desktop/STICS/Configuration files')
eval('config_05_26_2011_ch1_wt16_dt1_wx16_dx8')
cd(p)

%%%%%%%%%%%%%%%%%% Format image file %%%%%%%%%%%%%%%%
im = zeros([size(im0),num_frames]);
for j=1:channels
    for i = 1:num_frames
        im(:,:,i,j) = imread(io.file_name , channels*(i-1)+(j));
    end
end
clear im0

%%%%%%%%%%%%%%%%%% Cropping image %%%%%%%%%%%%%%%%%%%
imcrop = im(y0:yf,x0:xf,t0:t_f,ch);
% imsequence_play(imcrop)

%%%%%%%%%%%%%%%%%% STICS options %%%%%%%%%%%%%%%%%%%%
o.im = imcrop;
clear imcrop

%%%%%%%%%%%%%%%%%% Output Files %%%%%%%%%%%%%%%%%%%%
if (DEBUG), debug_flag = '_debug'; else debug_flag = ''; end
io.folder = folder_stem;
io.file_suffix = ['_ch',num2str(ch),'_wt',int2str(o.wt),'_wx',int2str(o.wx),'_dt',int2str(o.dt)];
io.save_name = [folder_stem,imname,io.file_suffix,debug_flag];
mkdir(io.save_name);
io.sticsSaveName = [io.save_name,'/stics',io.file_suffix,debug_flag];
display('Loaded data set:');
display(io.file_name)
display('Will save data to:')
display(io.sticsSaveName)

%%%%%%%%%%%%%%%%%% Estimated time %%%%%%%%%%%%%%%%%%
estimate_stics_time(o,0.03,1)
beep

%% STICS analysis
% matlabpool open 3 % open matlabworkers for parfor

dt = o.dt;
wt = o.wt;
tbegin = max(ceil(dt/2),ceil(wt/2));
tend = size(o.im,3) - max(ceil(dt/2),ceil(wt/2));
t = tbegin : dt : tend;

sec_per_frame = o.sec_per_frame;
um_per_px = o.um_per_px;

dx = o.dx;
dy = o.dy;
wx = o.wx;
wy = o.wy;
imcrop = o.im;
corrTimeLim = o.corrTimeLim;

[Xf Yf] = grid4stics(imcrop, dx, dy, wx, wy);
vector = cell(numel(t),1);
tic
for i = 1: numel(t)
    imser = imcrop(:,:,t(i)-ceil(wt/2)+1:t(i)-ceil(wt/2)+wt);
    [v Xf Yf] = stics_image(imser, dx, dy, wx, wy, sec_per_frame, um_per_px, corrTimeLim, corrTimeLim,'off');
    vector{i}=v;
    if mod(i,10)==0
        %save('results_stics')
    end
end
toc
display('Saving data to:')
display(io.sticsSaveName)

save(io.sticsSaveName)

% matlabpool close

%% STICS movie

% sticsLoadName = '~/Desktop/Mimi/Data/05-26-2011/SqhGFPGap43_Maximumintensityprojection_gauss1';
sticsLoadName = io.sticsSaveName;
load(sticsLoadName);
imcrop = o.im;

membranes = im(y0:yf,x0:xf,t0:t_f,2);
F = stics_movie(imcrop,o,vector,200);
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
