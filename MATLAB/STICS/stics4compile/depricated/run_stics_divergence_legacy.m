close all
clear all
% addpath('D:\network_simulator_0.2')
% addpath('D:\network_simulator_0.2\simulator')
% addpath('D:\network_simulator_0.2\utils')
% addpath('D:\network_simulator_0.2\tools_jun')
% addpath('D:\ICSMATLAB')
% addpath('D:\ICSMATLAB\ICS')
% addpath('D:\ICSMATLAB\imageManipulation')
% %addpath('D:\ICSMATLAB\simul8tr') % not using the old simulator
% addpath('D:\ICSMATLAB\STICS')
% addpath('D:\ICSMATLAB\TICS')


%%%%%%%%%%%%%%%%%% actin worm %%%%%%%%%%%%%%%%
num_frames = 686;
file_name = 'D:\Data\LifeactGFP_2_1s_ORIGINALMOVIE.tif';
im0 = imread(file_name );
im = zeros([size(im0),num_frames]);
for j=1:num_frames
im(:,:,j) = imread(file_name ,j);
end
%imsequence_play(im)

% %% crop out a sub image series, use one of the following
% imcrop = imsequence_crop(im); % manual crop imsequence
imcrop = im(109:172,516:579,1:300); % crop with specified coords
% imsequence_play(imcrop)

o.im = imcrop;
o.um_per_px = 0.15; %um
o.sec_per_frame = 5; %sec
o.dt = 5;
o.wt = 20;
o.dx = 8;
o.dy = 8;
o.wx = 16;
o.wy = 16;
o.corrTimeLim = 6;

%% new image series with averaged intensity over each spatial tempotal window
[Xf Yf] = grid4stics(o.im, o.dx, o.dy, o.wx, o.wy); % define grid for stics
tbegin = max(ceil(o.dt/2),ceil(o.wt/2));
tend = size(o.im,3) - max(ceil(o.dt/2),ceil(o.wt/2));
im_avg = zeros([size(Xf),size(o.im,3)]);
im_avg_resize = zeros(size(o.im));
clear im_avg_resize;
for k = tbegin: tend;
    for i = 1:size(Xf,1)
        for j = 1:size(Xf,2)
            sub_imser = o.im(Yf(i,j)-floor((o.wy-1)/2):Yf(i,j)+floor(o.wy/2), Xf(i,j)-floor((o.wx-1)/2):Xf(i,j)+floor(o.wx/2),k-ceil(o.wt/2)+1:k-ceil(o.wt/2)+o.wt);
            im_avg(i,j,k) = mean(sub_imser(:));
        end
    end
    im_avg_resize(:,:,k) = imresize(im_avg(:,:,k),size(o.im(:,:,1)));
end
for k = 1:tbegin-1;
    im_avg_resize(:,:,k) = im_avg_resize(:,:,tbegin);
end
for k =  tend:size(o.im,3);
    im_avg_resize(:,:,k) = im_avg_resize(:,:,tend);
end
% imsequence_play(im_avg_resize)
movie_size = 256;
figure(200)
for j = 1:size(o.im,3)
subplot(1,2,1)
imshow(imcrop(:,:,j),[])
set(gca, 'units', 'pixels', 'Position', [0 0 movie_size movie_size]);
set(gcf, 'units', 'pixels', 'Position', [250 250 2*movie_size+1 movie_size]);
subplot(1,2,2)
imshow(im_avg_resize(:,:,j),[])
hold on
contour(im_avg_resize(:,:,j))
hold off
set(gca, 'units', 'pixels', 'Position', [movie_size+1 0 movie_size movie_size]);
F(j) = getframe;
end
movie2avi(F,'raw_mean_images')

%% STICS analysis
matlabpool % open matlabworkers for parfor, if you dont have parallel tool box than comment this line

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


tic
parfor i = 1: numel(t);
    %tic
    imser = imcrop(:,:,t(i)-ceil(wt/2)+1:t(i)-ceil(wt/2)+wt);
    [v Xf Yf] = stics_image(imser, dx, dy, wx, wy, sec_per_frame, um_per_px, corrTimeLim,corrTimeLim,'off' ) 
    vector{i}=v;
    %toc
    if mod(i,10)==0
        %save('results_stics')
    end
end
toc
save('results_stics')

matlabpool close % close matlabworkers for parfor, if you dont have parallel tool box than comment this line
%% STICS movie

%load('results_stics_tics_actinworm_finer_grid.mat')
clear vector_frame F
I=1;
for j = 1:t(end)+floor(wt/2)
    if I<numel(t)
        if j<=t(I)+floor(dt/2)
            t(I)+floor(dt/2)
            vector_frame{j} = vector{I};
        else
            I=I+1;
            vector_frame{j} = vector{I};
        end
    else
         vector_frame{j} = vector{I};
    end    
    index(j) = I;
end


movie_size = 256;% in pix
figure(201)
for j = 1:t(end)+floor(wt/2)
imshow(imcrop(:,:,j),[])
axis on; hold on,
%plot(Xf,Yf,'b.','markersize',5)
velocity(:,:,:,j) = vector_frame{j}*60; % um/min
quiver(Xf,Yf,velocity(:,:,1,j), velocity(:,:,2,j), .9,'y')
set(gca, 'units', 'pixels', 'Position', [0 0 movie_size movie_size]);
set(gcf, 'units', 'pixels', 'Position', [250 250 movie_size movie_size]);

% putting scale bar
scalebar = 1; %scalebar length in um
offest = [0.05 0.05]; % text postion offest from scale bar
percent_len = scalebar/(size(imcrop,2)*o.um_per_px); %scalebar percentage length
line([size(imcrop,2)*(0.97-percent_len),size(imcrop,2)*0.97],[size(imcrop,1)*0.97,size(imcrop,1)*0.97],'color','w','linewidth',5)
text(size(imcrop,2)*(0.97-percent_len+offest(1)),size(imcrop,2)*(0.97-offest(2)), [num2str(scalebar),' \mum'],'color','w')

F(j) = getframe;
hold off
end
movie2avi(F,'movie3')

%% compute and plot divergence

clear mex F
movie_size = 256;
EF = 4; % exand_factor 
figure(10000)
for j = 1:t(end)+floor(wt/2)
div(:,:,j) = divergence(Xf,Yf,velocity(:,:,1,j), velocity(:,:,2,j));
end
for j = 1:t(end)+floor(wt/2)
surf(imresize(div(:,:,j),EF));

%axis tight
%axis equal
axis([1, size(velocity(:,:,1,1),1)*4, 1, size(velocity(:,:,1,1),2)*4])
colorbar
set(gca,'clim',[min(div(:)),  max(div(:))])

shading interp
set(gcf, 'renderer','zbuffer')
view([0 -90])
set(gca, 'units', 'pixels', 'Position', [1 1 movie_size-1 movie_size-1]);
set(gcf, 'units', 'pixels', 'Position', [250 250 movie_size+80 movie_size]);

% % % putting scale bar
% scalebar = 4; %scalebar length in um
% offest = [0.05 0.05]; % text postion offest from scale bar
% percent_len = scalebar/(size(div,2)*dx*o.um_per_px); %scalebar percentage length
% line([size(div,2)*EF*(0.97-percent_len),size(div,2)*EF*0.97],[size(div,1)*EF*0.97,size(div,1)*EF*0.97],[-max(div(:)) -max(div(:))],'color','b','linewidth',5)
% text(size(div,2)*EF*(0.97-percent_len+offest(1)),size(div,2)*EF*(0.97-offest(2)), -max(div(:)), [num2str(scalebar),' \mum'],'color','b')

F(j) = getframe(gcf);
end
movie2avi(F,'div_starfishpole_colorbar.avi','compression','None')


figure(2000)
hist(div(:),100) 
xlabel('div of velocity (min^{-1})')
ylabel('counts')
title('for all frames')

title({'Div for all frames',...
    ['Mean = ',num2str(mean2(div(:)),'%10.4f'),'min^{-1}'],...
    ['St. Dev. = ',num2str(std(div(:)),'%10.4f'),'min^{-1}']})


movie2avi(F,'div distribution of starfish pole.avi','compression','None')

