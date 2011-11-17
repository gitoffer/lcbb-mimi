function [stics_img,o] = bead_test2(opt,play,bayes_opt,showsurf)

[logs,~,~] = BD_simul8tr( [],opt);
[im,~] = image_generator(logs,opt);
while any(isnan(im))
    [logs,~,~] = BD_simul8tr( [],opt);
    [im,~] = image_generator(logs,opt);
end
if play
    imsequence_play(im);
end

%% STICS options
o = SticsOptions(opt.um_per_px,opt.sec_per_frame,32,32,64,64,64,64,opt.corrTimeLimit,1,1,1,1);

%% STICS analysis

tbegin = max(ceil(o.dt/2),ceil(o.wt/2));
tend = size(im,3) - max(ceil(o.dt/2),ceil(o.wt/2));
t = tbegin : o.dt : tend;

[Xf ~] = grid4stics(im, o.dx, o.dy, o.wx, o.wy);

%%%%%%

models = bayes_opt.model_list;

[X,Y] = size(Xf);
m = numel(models);
T = numel(t);

if o.bayes
    [stics_img(T,X,Y,m).model_name,...
        stics_img(T,X,Y,m).params, ...
        stics_img(T,X,Y,m).log_likelihood,...
        stics_img(T,X,Y,m).model_probability,...
        stics_img(T,X,Y,m).D,...
        stics_img(T,X,Y,m).vx,...
        stics_img(T,X,Y,m).vy]...
        = deal([],[],NaN,NaN,NaN,NaN,NaN);
else
    stics_img = cell(1,T);
end
% vector(T,X,Y,m) = BayesModels;
% tic

for i = 1: numel(t)
    imser = im(:,:,t(i)-ceil(o.wt/2)+1:t(i)-ceil(o.wt/2)+o.wt);
    if o.bayes
        [B Xf Yf] = stics_image_bayes(imser, o, bayes_opt, o.corrTimeLim,showsurf);
        stics_img(i,:,:,:)=B;
        %         B;
    else
        [v Xf Yf] = stics_image(imser, o, o.corrTimeLim,showsurf);
        stics_img{i} = v;
    end
end
% toc
end