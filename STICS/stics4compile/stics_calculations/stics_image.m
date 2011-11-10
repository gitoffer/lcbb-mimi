function [v Xf Yf] = stics_image(imser, o, varargin) 
% compute stic funcion for every grid point of a rectanglular meshgrid 
% specified by dx, dy,(point spcacing) wx, wy(window size)

% and below done with "stics_grid"
% fitting stic func to 2d gaussian to track peak position
% fitting peak position vs time to obtain velocity, plot velocity vector on the first image
% varargin{1}=fitting limit; varargin{2}= whether show stic func (on/off)
% Jun He, @MIT, Jan 16, 2010

dx = o.dx;
dy = o.dy;
wx = o.wx;
wy = o.wy;
sec_per_frame = o.sec_per_frame;
um_per_px = o.um_per_px;
corrTimeLim = o.corrTimeLim;

if isempty(varargin)
fitTimeLimit = corrTimeLim;
showsurf = 'off';
elseif numel(varargin)==1
fitTimeLimit = varargin{1};
showsurf = 'off';
else
fitTimeLimit = min(varargin{1},corrTimeLim);
showsurf = varargin{2};   
end

% specify meshgrid with dx, dy, wx, wy,
xbegin = max(ceil(dx/2),ceil(wx/2));
ybegin = max(ceil(dy/2),ceil(wy/2));
xend = size(imser,2) - max(ceil(dx/2),ceil(wx/2));
yend = size(imser,1) - max(ceil(dy/2),ceil(wy/2));
if xbegin<=xend & ybegin<=yend 
[Xf Yf] = meshgrid(xbegin: dx: xend, ybegin: dy: yend);
elseif xbegin>xend & ybegin<=yend 
[Xf Yf] = meshgrid(xbegin, ybegin: dy: yend);
elseif xbegin<=xend & ybegin>yend 
[Xf Yf] = meshgrid(xbegin: dx: xend, ybegin);
end

%call stics_grid
[v Xf Yf] = stics_grid(imser,Xf, Yf, wx, wy, sec_per_frame,um_per_px,corrTimeLim, fitTimeLimit,showsurf ) ;



% % 
% % for i = 1:size(Xf,1)
% %     for j = 1:size(Xf,2)
% %         sub_imser = imser(Yf(i,j)-floor((wy-1)/2):Yf(i,j)+floor(wy/2), Xf(i,j)-floor((wx-1)/2):Xf(i,j)+floor(wx/2),1:maxFrame);
% %         % crop out subimage with dimensions wx, wy, centered at grid point
% %         STCorr = stics(sub_imser, corrTimeLim); % compute stic funciton
% %         if strcmp(showsurf,'on')
% %             figure(30)
% %             plot(Xf(i,j),Yf(i,j),'.')
% %             axis on; hold on,
% %             imsequence_color(STCorr);
% %         end
% %         a{i,j} = gauss2d_fit(STCorr);% compute stic funciton
% %     end
% % end
% % for i = 1:size(Xf,1)
% %     for j = 1:size(Xf,2)
% %         v(i,j,:) = velocity_simple(a{i,j}(:,4:5), sec_per_frame, um_per_px,fitTimeLimit);
% %     end
% % end
% % 
% % speed = sqrt(v(:,:,1).^2 + v(:,:,2).^2 )
% % figure(gcf+1)
% % imshow(imser(:,:,1),[])
% % axis on; hold on,
% % plot(Xf,Yf,'b.','markersize',5)
% % quiver(Xf,Yf,v(:,:,1),v(:,:,2),.8,'y')
% % figure(gcf+1)
% % hist(speed(:))
% % title({'statistics of velocity:',['mean=',num2str(mean(speed(:)))],['median=',num2str(median(speed(:)))],['std=',num2str(std(speed(:)))]},'FontSize',12)
