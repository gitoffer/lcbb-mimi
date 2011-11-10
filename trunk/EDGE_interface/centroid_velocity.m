function [vx,vy] = centroid_velocity(x,y,frames)

[T,N] = size(x);

if ~exist('frames','var')
    frames = 1:T;
end

x = x(frames,:);
y = y(frames,:);

T = numel(frames);

x_sm = smooth2a(x,2,0);
y_sm = smooth2a(y,2,0);

vx = diff(x_sm,1);
vy = diff(y_sm,1);

% v = sqrt(vx.^2 + vy.^2);
fig1 = figure;
scnsize = get(0,'ScreenSize');
set(fig1,'Position',[1 1 scnsize(3)/2 scnsize(4)/2]);

for i = 1:T-1
    quiver(x(i,:),y(i,:),vx(i,:),vy(i,:),.5);
    axis([60 150 25 65])
    axis equal

    drawnow;
    F(i) = getframe;
end
movie2avi(F,'cell_centroid_velocities');
