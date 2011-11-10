function frames = play_stack(im_stack,varargin)
% plays an image stack stored in a 3-D array (x,y,depth or time)
%
% as a movie at about 24 frames per second
%
% K. Titievsky
% kir@mit.edu
% Feb 27, 2009

% interpret optional arguments
figure(501)
o_default = struct('frame_rate', 24 ...
    , 'xrange', 1:size(im_stack,2) ...
    , 'yrange', 1:size(im_stack,1) ... % show pixels only in window (x0 y0 x1 y1)
    , 'loop',   0  ... % loop the video
    , 'stretch_each', 0 ...
    , 'do_this', '' ... % execute this function for every frame with frame number as argument
    );
o = merge_ops(varargin, o_default);

% to make things go faster, user lower precision data
im_stack = double(im_stack(o.yrange, o.xrange, :));

% set up the figure;

window_size = 512;
set(gca, 'units', 'pixels', 'Position', [0 0 window_size window_size]);
set(gcf, 'units', 'pixels', 'Position', [250 250 window_size window_size]);

axis off;

% set the colormap to be green shades, to mimic fluorescent images
c = colormap('gray');
c(:,[1 3]) = 0;

colormap(c);
im_stack = stretch(im_stack);

t = 0;
while true
    tic;
    t = t + 1;
    if t > size(im_stack,3)
        t = t - size(im_stack,3);
    end
    
    z = im_stack(:,:,t);
    if o.stretch_each
        z = stretch(z);
    end
    if t == 1
        im_handle = imshow(z);
        colormap(c);
        
    else % to speed up rendering we do not rebuild the entire graphics object every time
        try
            set(im_handle, 'CData', z);
        catch
            fprintf('Error. Stopping %s\n', mfilename);
            return;
        end
   
    end
    % wait a bit to set the pace.
    pause(max(0, 1/o.frame_rate-toc));
    if nargout > 0
        frames(t) = getframe();
    end
    if ~isempty(o.do_this)
        hold on;
        feval(o.do_this, t);
        
    end
    if t == 1
        im_handle = imshow(z);
        colormap(c);
        
    else % to speed up rendering we do not rebuild the entire graphics object every time
        try
            set(im_handle, 'CData', z);
        catch
            fprintf('Error. Stopping %s\n', mfilename);
            return;
        end
        % wait a bit to set the pace.
        pause(max(0, 1/o.frame_rate-toc));
        if nargout > 0
            frames(t) = getframe();
        end
        if ~isempty(o.do_this)
            hold on;
            feval(o.do_this, t);
            
        end
        if ~o.loop && (t == size(im_stack,3))
            break;
        end
    end
    
    i=t;
    F(i) = getframe;
    
end
%movie2avi(F,'movie3')