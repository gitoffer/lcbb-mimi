function [v Xf Yf] = stics_grid(imser,Xf, Yf, wx, wy, sec_per_frame,um_per_px,corrTimeLim, varargin) 
% compute stic funcion for every grid point,of subimage size wx, wy, meshgrid input as Xf, Yf, 
% fitting stic func to 2d gaussian to track peak position
% fitting peak position vs time to obtain velocity, plot velocity vector on the first image
% varargin{1}=fitting limit; varargin{2}= whether show stic func (on/off)
% Jun He, @MIT, Jan 16, 2010
maxFrame = size(imser,3);
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

frame1 =imser(:,:,1);
a = cell(size(Xf));

for i = 1:size(Xf,1)
    for j = 1:size(Xf,2)
        sub_imser = imser(Yf(i,j)-floor((wy-1)/2):Yf(i,j)+floor(wy/2), Xf(i,j)-floor((wx-1)/2):Xf(i,j)+floor(wx/2),1:maxFrame);
        % crop out subimage with dimensions wx, wy, centered at grid point
        STCorr = stics(sub_imser, corrTimeLim); % compute stic funciton
        if strcmp(showsurf,'on')
            figure(30)
            frame1(Yf(i,j)-floor((wy-1)/2):Yf(i,j)+floor(wy/2), Xf(i,j)-floor((wx-1)/2):Xf(i,j)+floor(wx/2))...
                =frame1(Yf(i,j)-floor((wy-1)/2):Yf(i,j)+floor(wy/2), Xf(i,j)-floor((wx-1)/2):Xf(i,j)+floor(wx/2))-0.5*mean(imser(:));
            imshow(frame1,[]);
            hold on
            plot(Xf(i,j),Yf(i,j),'.')
            axis on; hold on;
            imsequence_color(STCorr);
        end
        a{i,j} = gauss2d_fit(STCorr);% compute stic funciton
    end
end
v = zeros([size(Xf),2]);
for i = 1:size(Xf,1)
    for j = 1:size(Xf,2)
        v(i,j,:) = velocity_simple(a{i,j}(:,4:5), sec_per_frame, um_per_px,fitTimeLimit);
    end
end
% 
% speed = sqrt(v(:,:,1).^2 + v(:,:,2).^2 )
% figure(31)
% imshow(imser(:,:,1),[])
% axis on; hold on,
% plot(Xf,Yf,'b.','markersize',5)
% quiver(Xf,Yf,v(:,:,1),v(:,:,2),.8,'y')
% figure(32)
% hist(speed(:))
% title({'statistics of speed:',['mean=',num2str(mean(removenan(speed(:))))],['median=',num2str(median(removenan(speed(:))))],['std=',num2str(std(removenan(speed(:))))]},'FontSize',12)
