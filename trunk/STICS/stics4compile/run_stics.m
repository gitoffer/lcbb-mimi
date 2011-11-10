function run_stics(config_file,num_workers)

%%%%%%%%%%%%%%%%%% Run Configuration file %%%%%%%%%%%
cd('~/Desktop/MATLAB Library/STICS/Configuration files/To be run');
eval(config_file)
stics_opt = SticsOptions(um_per_px,sec_per_frame,dt,wt,dx,dy,wx,wy,...
    corrTimeLim,origial_dimensions,crop,ch,bayes);
cd('~/Desktop/MATLAB Library/STICS/stics4compile');

%%%%%%%%%%%%%%%%%% Cropping image %%%%%%%%%%%%%%%%%%%
imcropped = im(y0:yf,x0:xf,t0:t_f,ch);
% imsequence_play(imcrop)
clear im;

%%%%%%%%%%%%%%%%%% Output Files %%%%%%%%%%%%%%%%%%%%
io = SticsIo(imname,folder_stem,stics_opt,custom);

%% STICS analysis

if num_workers > 1
    eval(['matlabpool ' int2str(num_workers)])
end

tbegin = max(ceil(stics_opt.dt/2),ceil(stics_opt.wt/2));
tend = size(imcropped,3) - max(ceil(stics_opt.dt/2),ceil(stics_opt.wt/2));
t = tbegin : stics_opt.dt : tend;

%%%%%% Set up models

models = {
    'mixed_model', ...
    'diffusion_model', ...
    'convection_model', ...
    'noise_model' ...
    };

photobleaching = 0;
weighted_fit = 1;
psf_size = .4;
bayes_opt = BayesOptions(models,photobleaching,weighted_fit,psf_size);

%%%%%% STICS calculations (Variables redeclared for parloop)
T = numel(t);
stics_img = cell(T,1);
wt = stics_opt.wt;
bayes = stics_opt.bayes;
corrTimeLim = stics_opt.corrTimeLim;

tic
parfor i = 1: numel(t)
    imser = imcropped(:,:,t(i)-ceil(wt/2)+1:t(i)-ceil(wt/2)+wt);
    if bayes
        [B Xf Yf] = stics_image_bayes(imser,stics_opt,bayes_opt,corrTimeLim,'off');
        stics_img{i}=B;
%         B;
    else
        [v Xf Yf] = stics_image(imser,stics_opt,corrTimeLim,'off');
        stics_img{i} = v;
    end
    display(['Time ' num2str(i) ' finished.'])
end
toc

display('Saving data to:')
display(io.sticsSaveName)

save(io.sticsSaveName)

if num_workers > 1
    eval('matlabpool close')
end
end
