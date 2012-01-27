function F = stics_movie(image,o,vector,scaleFactor)

clear vector_frame F
clf

EF = 1.5;
dt = o.dt;
wt = o.wt;
tbegin = max(ceil(dt/2),ceil(wt/2));
tend = size(image,5) - max(ceil(dt/2),ceil(wt/2));
t = tbegin : dt : tend;
[Xf Yf] = grid4stics(image, o.dx, o.dy, o.wx, o.wy);

I = floor(wt/2):numel(t);
j = 1:t(end) + floor(wt/2);
I_left = I(ones(1,floor(wt/2)-1));
I = [I_left,I];
I_right = I(ones(1,numel(j) - numel(I))*end);
I = [I,I_right];

vector_frame = vector(I);

% movie_size = 256*EF;% in pix
% figure(201)
[resized ~] = imresize(image,EF);
clear F;
velocity = zeros([size(vector_frame{1}),t(end)+floor(wt/2)]);

for j = 1:t(end)+floor(wt/2)
    imshow(resized(:,:,j),[])
    hold on
    %plot(Xf,Yf,'b.','markersize',5)
    velocity(:,:,:,j) = vector_frame{j}*scaleFactor; % um/min (Mimi: Actuallly um/sec?)
    quiver(EF*Xf,EF*Yf,velocity(:,:,1,j), velocity(:,:,2,j), 0,'y','Linewidth',1)
%     set(gca, 'units', 'pixels', 'Position', [0 0 movie_size movie_size]);
%     set(gcf, 'units', 'pixels', 'Position', [250 250 movie_size movie_size+EF0]);
    title(['wt:',int2str(o.wt),' wx:',int2str(o.wx),' dt:',int2str(o.dt)]);

    % putting in a scale bar
    scalebar = 1; %scalebar length in um
    offest = [.0 .05]; % text postion offest from scale bar
    percent_len = scalebar/size(image,2)/o.um_per_px; %scalebar percentage length
    line([size(image,2)*EF*(0.9-percent_len),size(image,2)*EF*0.9],[size(image,1)*EF*0.97,size(image,1)*EF*0.97],'color','w','linewidth',5)
    text(size(image,2)*EF*(0.90-percent_len+offest(1)),size(image,1)*EF*(0.98-offest(2)), [num2str(scalebar),' \mum'],'color','w')
    
    F(j) = getframe;
    pause(1)
    hold off
end
movie(F);