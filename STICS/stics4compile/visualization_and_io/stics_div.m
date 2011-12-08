function varargout = stics_div(stics_img,stics_opt,Xf,Yf,io,opt)
%STICS_DIV Takes the divergence of a vector field returned by STICS.
%
% SYNPSIS: varargout = stics_div(stics_img,stics_opt,io,opt)
%
% INPUT: stics_img - STICS output
%        stics_opt - STICS options object
%        io - STICS io object
%        opt (optional) - structure of options
%           .scaling - scaling factor (default = 1)
%           .scaling - movie_size (default = 256*3)
%           .scaling - histogram (default = 'off')
%
% OUTPUT: [F] = stics_div(...) - returns divergence movie
% 	      [F,div] = stics_div(...) - returns movie and div
%         [F,counts,bins] = stics_div(...) - returns movie, div, and
%         histogram statistics
%
% Jun He @ mit 2010. xies@mit Nov 2011.

if ~exist('opt','var'), scaling = 1; histogram = 'off'; movie_size = 256*3;
else
if ~isfield(opt,'scaling'), scaling = 1; else scaling = opt.scaling; end
if ~isfield(opt,'histogram'), histogram = 'off'; else histogram = opt.histogram; end
if ~isfield(opt,'movie_size'), movie_size = 256*3; else movie_size = opt.movie_size; end
end

wx = stics_opt.wx;
wt = stics_opt.wt;
dt = stics_opt.dt;
crop = stics_opt.crop;
tf = crop(6);

tbegin = max(ceil(dt/2),ceil(wt/2));
tend = tf - max(ceil(dt/2),ceil(wt/2));
t = tbegin : dt : tend;

I = floor(wt/2):numel(t);
j = 1:t(end) + floor(wt/2);
I_left = I(ones(1,floor(wt/2)-1));
I = [I_left,I];
I_right = I(ones(1,numel(j) - numel(I))*end);
I = [I,I_right];
vector_frame = stics_img(I);

figure(10000)
% Preallocate
div = zeros(size(stics_img{1},1),size(stics_img{1},2),t(end)+floor(wt/2));
% for j = 1:numel(t)
%     v = stics_img{j};
%     div(:,:,j) = divergence(Xf,Yf,v(:,:,1), v(:,:,2));
% end
for j = 1:t(end)+floor(wt/2)
    
    velocity = vector_frame{j};
    div(:,:,j) = divergence(Xf,Yf,velocity(:,:,1),velocity(:,:,2));
    % Plot the interpolated divergence as a surface, wth scaling factor
    surf(imresize(div(:,:,j),scaling))
    
    axis equal
    axis([1, size(div(:,:,1,1),2)*scaling, 1, scaling*size(div(:,:,1,1),1)]);
%     set(gca,'Clim',[nanmin(min(div(:,:,j))), max(max(div(:,:,j)))])
    set(gca,'YDir','normal')
    colorbar;
    title(['Divergence map for frame', num2str(j), ' wt:',int2str(wt),' wx:',int2str(wx),' dt:',int2str(dt)]);
    
    shading interp
    set(gcf, 'renderer','zbuffer')
    view([0 -90])
    set(gcf, 'units', 'pixels', 'Position', [250 250 movie_size-100 movie_size+10]);
    
    % % % putting scale bar
    % scalebar = 4; %scalebar length in um
    % offest = [0.05 0.05]; % text postion offest from scale bar
    % percent_len = scalebar/(size(div,2)*dx*o.um_per_px); %scalebar percentage length
    % line([size(div,2)*EF*(0.97-percent_len),size(div,2)*EF*0.97],[size(div,1)*EF*0.97,size(div,1)*EF*0.97],[-max(div(:)) -max(div(:))],'color','b','linewidth',5)
    % text(size(div,2)*EF*(0.97-percent_len+offest(1)),size(div,2)*EF*(0.97-offest(2)), -max(div(:)), [num2str(scalebar),' \mum'],'color','b')
    
    F(j) = getframe(gcf);
end
% Make a movie
movie(F)

% Return a histogram of divergence magnitudes
if strcmpi(histogram,'on')
    figure(2000)
    hist(div(:),100);
    [counts,bins] = hist(div(:),100);
    xlabel('div of velocity (min^{-1})')
    ylabel('counts')
    title('for all frames')
    
    title({'Div for all frames',...
        ['Mean = ',num2str(mean2(div(:)),'%10.4f'),'min^{-1}'],...
        ['St. Dev. = ',num2str(std(div(:)),'%10.4f'),'min^{-1}']})
end

switch nargout
    case 1, varargout{1} = F;
    case 2, varargout{2} = div;
    case 4, varargout{3} = counts; varargout{4} = bins;
    otherwise, error('Wrong number of outputs (1, 2, or 4).');
end

end