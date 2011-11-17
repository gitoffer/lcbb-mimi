% Script to test Bayesian model selection for STICS correlation functions
% generated from simulated bead images
clear variables
close all
clc

VERBOSE = 2;

%% Bead simulation parameters
% The 'ground truth' used to generate the bead images

clear opt
J = 10; % Number of different sampling of a parameter sweep
for i = 1:J
    opt(i) = struct( ...
        ...%%%%%%%% parameters for Brownian dynamics simulation %%%%%%%%%%%%%%%%
        'n_dims', 2 ...      %  number of dimensions in which the simulation is conducted
        , 'sim_box_size_um',  [2 2 0].^7.*1 ...  % the simulated box is of this size. See code below for actual default value (should be box_size_px*um_per_px)
        , 'num_frames',     32 ...			% number of frames in the stack produced by the code
        , 'density',        10 ...              % density of the particles, in um^-o.n_dims
        , 'um_per_px',      .1 ...			% resolution, microns per pixel
        , 'sec_per_frame',  .1 ...		% seconds per frame
        ...
        , 'diff_coeff',    (0.05*(11-i)) ...              	% diffusion coefficient in micron^2/sec
        , 'u_convection',  [0 0 0] + 0*[.5 .5 0] ...        	% convection velocity in microns/sec
        , 'make_gradient' , 0 ...
        ...
        ...%%%%%%%% parameters for image generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        , 'box_size_px',    [2 2 0].^6 ...  	% size of the images.
        , 'psf_type', 'g' ...            	% only gaussian psf ('g') is currently supported
        , 'psf_sigma_um',   [0.5 0.5 0.7] ...  	% standard deviation of the psf in microns, indepedent for all three directions
        , 'renderer', 'points_from_nodes' ...  	%   'lines_from_bonds' or 'points_from_nodes'.
        ...
        , 'signal_level',      200 ...                %signal level above background
        , 'signal_background', 100 ...  % relative to signal at beads of 1.0
        , 'counting_noise_factor', 2 ...		% counting noise  factor (noise = sqrt(o.counting_noise_factor*imageFinal).*randn(im_dims)  1.327
        , 'dk_background',     0 ...   % dark background average 189.462
        , 'dk_noise',          0 ...         % dark noise rms(std)%7.265
        ...
        , 'finer_grid' , 1 ... %%% to more accurately simulate bead position
        , 'store_x', 1 ...
        ...
        ...%%%%%%%% parameters for data analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        , 'corrTimeLimit', 5 ...
        , 'speed', NaN ...
        , 'snr', NaN ...
        , 'Pe', NaN ...
        , 'num_runs', 5 ...
        );
    opt(i).speed = sqrt(sum([opt(i).u_convection].^2));
    opt(i).Pe = dot(abs(opt(i).u_convection),opt(i).psf_sigma_um)/opt(i).diff_coeff;
    opt(i).snr = opt(i).signal_level /...
        sqrt(opt(i).counting_noise_factor*opt(i).signal_background + opt(i).dk_noise*opt(i).dk_noise);
end

models = {
    'mixed_model', ...
    'diffusion_model', ...
    'flow_model', ...
    'noise_model' ...
    };

photobleaching = 0;
weighted_fit = 1;
psf_size = .5;
window = 200;
bayes_opt = BayesOptions(models,photobleaching,weighted_fit,psf_size,window);

%% Run test
% Perform Bayesian model selection and parameter fitting

% matlabpool open 4
K = 1; % Different independent simulations and fittings
num_mov = 1;
stics_img = cell(J,K);

for j = 1:J
    display('.');
    display(['Creating ' int2str(j) '/' int2str(J) ' bead setting.']);
    disp('.');
    display(['Diffusion coefficient ' num2str(opt(j).diff_coeff) ...
        '; velocity ' num2str(opt(j).u_convection) '; snr ' ...
        num2str(opt(j).snr)]); 
    for k = 1:K
        
        if VERBOSE
            display(['(' int2str(k) '/' int2str(K) ')'])
        else
            fprintf('%s','.');
        end
        showsurf = 'off';
        play = 0;
        if k== 1 && (mod(j,10) == 1)
            showsurf = 'on';
            play = 1;
        end
        [stics_img{j,k},o] = bead_test2(opt(j),play,bayes_opt,showsurf);

    end
    
%     save('v_vary_D_2_CDMN_psf_dot1')
    
end
% matlabpool close

%% Parse the information into an array.
% Useful because we assume each STICS window will have the same
% information, so we can average across them
clear OUTPUT
for j = 1:J
    for k = 1:K
        foo = stics_img{j,k};
        foo = shiftdim(foo,1);
        [L,M,I] = size(foo);
        for l = 1:L
            for m = 1:M
                for i = 1:I
                    OUTPUT(j,k,l,m,i) = foo(l,m,i);
                end
            end
        end
    end
end

%% Flow model - use this for grid representation of fitted velocities

for j = 1:J
    for k = 1:K
        for l = 1:L
            for m = 1:M
                sorted_array = sort_models_by_prob(squeeze(OUTPUT(j,k,l,m,:)));
                most_probable_model(j,k,l,m) = sorted_array(1);
                if (strcmpi(most_probable_model(j,k,l,m).model_name,'convection_model') ...
                        || strcmpi(most_probable_model(j,k,l,m).model_name,'mixed_model'))
                    this = most_probable_model(j,k,l,m);
                    conv_vx(j,k,l,m) = this.vx;
                    conv_vy(j,k,l,m) = this.vy;
                end
            end
        end
    end
end

for j = 1:J-5
    flat = @(x) x(:);
    current_vx = flat(conv_vx(j,:,:,:));
    current_vy = flat(conv_vy(j,:,:,:));
    nonzero_vx{j} = current_vx(current_vx ~= 0);
    nonzero_vy{j} = current_vy(current_vy ~= 0);
end

%% Quiver plot of fitted v. real velocities
for j = 1:J
%     for k = 1:K
        u = opt(j).u_convection;
        real_vx = u(1);
        real_vy = u(2);
        quiver(ones(L,M)*real_vx,ones(L,M)*real_vy,0);
        hold on
        quiver(squeeze(mean(conv_vx(j,k,:,:),2)),squeeze(mean(conv_vy(j,k,:,:),2)),0);
        hold off
        pause(1);
%     end
end

%% Use this to plot total model probabilities given data

figure
clear diffusion flow mixed noise
for j =1:J
    for k = 1:K
        for l = 1:L
            for m = 1:M
                diffusion(j,k,l,m) = OUTPUT(j,k,l,m,2);
                flow(j,k,l,m) = OUTPUT(j,k,l,m,3);
                mixed(j,k,l,m) = OUTPUT(j,k,l,m,1);
                noise(j,k,l,m) = OUTPUT(j,k,l,m,4);
            end
        end
    end
end

% visualize model probabilities
pe = [opt.diff_coeff];

h = errorbar(pe, ...
    mean(reshape([flow.model_probability],J,K*L*M),2), ...
    std(reshape([flow.model_probability],J,K*L*M),0,2),'b-');
hold on
errorbar(pe, ...
    mean(reshape([diffusion.model_probability],J,K*L*M),2), ...
    std(reshape([diffusion.model_probability],J,K*L*M),0,2),'r-');
errorbar(pe, ...
    mean(reshape([noise.model_probability],J,K*L*M),2), ...
    std(reshape([noise.model_probability],J,K*L*M),0,2),'k-');
errorbar(pe, ...
    mean(reshape([mixed.model_probability],J,K*L*M),2), ...
    std(reshape([mixed.model_probability],J,K*L*M),0,2),'g-');
hold off

V = axis;
axis([V(1) V(2) 0 1])
title('Bayesian model probabilities for PSF size 0.5 \mum. Speed = 0 \mum/s. SNR = Inf');
legend('flow','diffusion','noise','mixed');
xlabel('Diffusion coefficient (\mu^2/sec)')

%% Plot parameters.
% Will visualize parameter if and only if it is the most likely parameter.
% E.g. if convection model is no the most likely model, then the velocity
% associated with it will not be displayed. Will average across independent
% fittings, aka across bead simulations (k) and across different STICS
% windows.
clear curr_vx curr_vy curr_D real_vx real_vy D D_std vx_std vy_std

vx = nan(J,1);
vy = vx;
vx_std = vx;
vy_std = vx;
D = vx;

for j = 1:J
    u = opt(j).u_convection;
    real_vx(j) = u(1);
    real_vy(j) = u(2);
    curr_vx = [];
    curr_vy = [];
    curr_D = [];
    for k = 1:K
        for l = 1:L
            for m = 1:M
                if strcmpi(most_probable_model(j,k).model_name,'convection_model')
                    curr_vx = [curr_vx convection(j,k,m,l).vx];
                    curr_vy = [curr_vy convection(j,k,m,l).vy];
                elseif strcmpi(most_probable_model(j,k,m,l).model_name,'diffusion_model')
                    curr_D = [curr_D diffusion(j,k,m,l).D];
                elseif strcmpi(most_probable_model(j,k,m,l).model_name,'mixed_model')
                    curr_vx = [curr_vx mixed(j,k,m,l).vx];
                    curr_vy = [curr_vy mixed(j,k,m,l).vy];
                    curr_D = [curr_D mixed(j,k,m,l).D];
                end
            end
        end
    end
    vx(j) = mean(curr_vx);
    vx_std(j) = std(curr_vx);
    vy(j) = mean(curr_vy);
    vy_std(j) = std(curr_vy);
    D(j) = mean(curr_D);
    D_std(j) = std(curr_D);
    pe(j) = opt(j).Pe;
end

pe = [opt.diff_coeff]';

h1 = errorbar(pe,vx,vx_std,'b-');
hold on
% errorbar(pe,nobayes_vx,nobayes_vx_std,'g-')
plot(pe,real_vx,'r-')
xlabel('Diffusion coefficient (\mu^2/sec)')
ylabel('Fitted v_x (\mu m / sec)')
title('Bayes parameters. SNR = Inf')

figure
h2 = errorbar(pe,vy,vy_std,'b-');
hold on
% errorbar(pe,nobayes_vx,nobayes_vx_std,'g-')
plot(pe,real_vy,'r-')
xlabel('Diffusion coefficient (\mu^2/sec)')
ylabel('Fitted v_y (\mu m / sec)')
title('Bayes parameters. SNR = Inf')

figure
h3 = errorbar(pe,D,D_std,'b-');
hold on
plot(pe,[opt.diff_coeff],'r-')
xlabel('Diffusion coefficient (\mu^2/sec)')
ylabel('Fitted D (\mu m^2 / sec)')
title('Bayes parameters. SNR = Inf')