function [vx,vy,varargout] = centroid_velocity(x,y,frames,disp)
%CENTROID VELOCITY Calculate the velocity of the centroids X,Y for a set of
%cells.
%
% USE: [Vx,Vy] = centroid_velocity(x,y,frames)
% USE: [Vx,Vy] = centroid_velocity(x,y,frames,'on') Turn on display

[T,N] = size(x);

if ~exist('frames','var'), frames = 1:T; end
if ~exist('disp','var'), disp = 'off'; end

x = x(frames,:);
y = y(frames,:);

T = numel(frames);

vx = central_diff_multi(x,1);
vy = central_diff_multi(y,1);

% v = sqrt(vx.^2 + vy.^2);
if strcmpi(disp,'on')
    fig1 = figure;
    scnsize = get(0,'ScreenSize');
    set(fig1,'Position',[1 1 scnsize(3)/2 scnsize(4)/2]);
    
    for i = 1:T-1
        axis([60 150 25 65]);
        axis equal
        
        drawnow;
        F(i) = getframe;
    end
	varargout{1} = F;
    
end


end