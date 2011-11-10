function [vector,o] = bead_test2_nobayes(opt)

[logs,~,~] = BD_simul8tr( [],opt);
[im,~] = image_generator(logs,opt);
while any(isnan(im))
    [logs,~,~] = BD_simul8tr( [],opt);
    [im,~] = image_generator(logs,opt);
end

% imsequence_play(im);

%% STICS options
% last stics_option argument is bayes
o = stics_option(im,opt.um_per_px,opt.sec_per_frame,64,32,16,16,32,32,opt.corrTimeLimit,1,1,1,0);

%% STICS analysis

tbegin = max(ceil(o.dt/2),ceil(o.wt/2));
tend = size(o.im,3) - max(ceil(o.dt/2),ceil(o.wt/2));
t = tbegin : o.dt : tend;

imcrop = o.im;
[Xf ~] = grid4stics(imcrop, o.dx, o.dy, o.wx, o.wy);

%%%%%%

[X,Y] = size(Xf);
T = numel(t);

vector = cell(T,1);
% tic

for i = 1: T
    imser = imcrop(:,:,t(i)-ceil(o.wt/2)+1:t(i)-ceil(o.wt/2)+o.wt);
    if o.bayes
        [B Xf Yf] = stics_image_bayes(imser, o, bayes_opt, o.corrTimeLim,'on');
        bstics(i,:,:,:)=B;
%         B;
    else
        [v Xf Yf] = stics_image(imser, o, o.corrTimeLim,'off');
        vector{i} = v;
    end
end
% toc
end