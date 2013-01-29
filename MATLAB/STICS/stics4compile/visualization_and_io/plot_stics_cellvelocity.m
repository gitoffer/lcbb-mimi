function F = plot_stics_cellvelocity(image,o,vector,scaleFactor,x,y)

clear vector_frame F
clf

EF = 1.5;
dt = o.dt;
wt = o.wt;
tbegin = max(ceil(dt/2),ceil(wt/2));
tend = size(image,3) - max(ceil(dt/2),ceil(wt/2));
t = tbegin : dt : tend;
[Xf Yf] = grid4stics(image, o.dx, o.dy, o.wx, o.wy);
[frames zstack cells] = size(x);

% STICS vector frame
I=1;
for j = 1:t(end)+floor(wt/2)
    if I<numel(t)
        if j<=t(I)+floor(dt/2)
            t(I)+floor(dt/2);
            vector_frame{j} = vector{I};
        else
            I=I+1;
            vector_frame{j} = vector{I};
        end
    else
        vector_frame{j} = vector{I};
    end
end

% Calculate instantaneous velocities
vx = zeros(frames,cells);
vy = zeros(frames,cells);
for i = 1:cells
    vx(:,i) = take_derivative(x(:,:,i),o.wt)/o.sec_per_frame;
    vy(:,i) = take_derivative(y(:,:,i),o.wt)/o.sec_per_frame;
end

% movie_size = 256*EF;% in pix
figure(201)
resized = imresize(image,EF);
clear F;
velocity = zeros([size(vector_frame{1}),t(end)+floor(wt/2)]);

for j = 1:t(end)+floor(wt/2)
    imshow(resized(:,:,j),[])
    hold on
    %plot(Xf,Yf,'b.','markersize',5)
    velocity(:,:,:,j) = vector_frame{j}*scaleFactor; % um/min
    quiver(EF*Xf,EF*Yf,velocity(:,:,1,j), velocity(:,:,2,j), 0,'y')
%     set(gca, 'units', 'pixels', 'Position', [0 0 movie_size movie_size]);
%     set(gcf, 'units', 'pixels', 'Position', [250 250 movie_size movie_size+EF0]);
    title(['wt:',int2str(o.wt),' wx:',int2str(o.wx),' dt:',int2str(o.dt)]);

    % putting in a scale bar
    scalebar = 1; %scalebar length in um
    offest = [.0 .05]; % text postion offest from scale bar
    percent_len = scalebar/size(image,2)/o.um_per_px; %scalebar percentage length
    line([size(image,2)*EF*(0.9-percent_len),size(image,2)*EF*0.9], ...
        [size(image,1)*EF*0.97,size(image,1)*EF*0.97],'color','w','linewidth',5);
    text(size(image,2)*EF*(0.90-percent_len+offest(1)),size(image,1)*EF*(0.98-offest(2)), ...
        [num2str(scalebar),' \mum'],'color','w');
    
    % Cell velocities
    ColorSet = varycolor(cells);
    set(gca,'ColorOrder',ColorSet);
    hold all
    for i = 1:cells
%         plot(EF*x(:,:,i),EF*y(:,:,i),'MarkerSize',100);
        quiver(EF*x(j,:,i),EF*y(j,:,i),scaleFactor*vx(j,i),scaleFactor*vy(j,i),'LineWidth',1.5);
        
    end
    
    F(j) = getframe;
    hold off
end
movie(F);