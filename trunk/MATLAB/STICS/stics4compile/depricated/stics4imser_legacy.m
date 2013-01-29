% open 4 matlab workers
matlabpool open 4
addpath('C:\Documents and Settings\Jun He\My Documents\MATLAB\stics4compile')

%%
% STICS analysis
load('data');

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

matlabpool close
%% STICS movie

% %load('results_stics_tics_actinworm_finer_grid.mat')
% clear vector_frame F
% I=1;
% for j = 1:t(end)+floor(wt/2)
%     if I<numel(t)
%         if j<=t(I)+floor(dt/2)
%             t(I)+floor(dt/2)
%             vector_frame{j} = vector{I};
%         else
%             I=I+1;
%             vector_frame{j} = vector{I};
%         end
%     else
%          vector_frame{j} = vector{I};
%     end    
%     index(j) = I;
% end
% 
% 
% movie_size = 256;% in pix
% figure(201)
% for j = 1:t(end)+floor(wt/2)
% imshow(imcrop(:,:,j),[])
% axis on; hold on,
% %plot(Xf,Yf,'b.','markersize',5)
% velocity(:,:,:,j) = vector_frame{j}*60; % um/min
% quiver(Xf,Yf,velocity(:,:,1,j), velocity(:,:,2,j), .9,'y')
% set(gca, 'units', 'pixels', 'Position', [0 0 movie_size movie_size]);
% set(gcf, 'units', 'pixels', 'Position', [250 250 movie_size movie_size]);
% 
% putting scale bar
% scalebar = 1; %scalebar length in um
% offest = [0.05 0.05]; % text postion offest from scale bar
% percent_len = scalebar/(size(imcrop,2)*o.um_per_px); %scalebar percentage length
% line([size(imcrop,2)*(0.97-percent_len),size(imcrop,2)*0.97],[size(imcrop,1)*0.97,size(imcrop,1)*0.97],'color','w','linewidth',5)
% text(size(imcrop,2)*(0.97-percent_len+offest(1)),size(imcrop,2)*(0.97-offest(2)), [num2str(scalebar),' \mum'],'color','w')
% 
% F(j) = getframe;
% hold off
% end
% movie2avi(F,'movie3')