% Script to test Bayesian model selection for STICS correlation functions
% generated from simulated bead images
clear all
close all
clc

% VERBOSITY
% 0 - No output at all except final parameter setting and model probability
% for each srun, and the final probability plot
% 1 - Plots the experimental correlation functions
% 2 - Outputs the current simulation step, and the current setting being
% fitted
VERBOSE = 2;

%% Bead simulation parameters
% The 'ground truth' used to generate the bead images

J = 10; % Number of different sampling of a parameter sweep
for i = 1:J
    opt(i) = struct( ...
        ...%%%%%%%% parameters for Brownian dynamics simulation %%%%%%%%%%%%%%%%
        'n_dims', 2 ...      %  number of dimensions in which the simulation is conducted
        , 'sim_box_size_um',  [2 2 0].^9 * 0.0645 ...  % the simulated box is of this size. See code below for actual default value (should be box_size_px*um_per_px)
        , 'num_frames',     64 ...			% number of frames in the stack produced by the code
        , 'density',        100 ...              % density of the particles, in um^-o.n_dims
        , 'um_per_px',      0.1 ...			% resolution, microns per pixel
        , 'sec_per_frame',  0.1 ...		% seconds per frame
        ...
        , 'diff_coeff',    .5 ...              	% diffusion coefficient in micron^2/sec
        , 'u_convection',   [2 2 0] + [0.5 0.5 0] ...        	% convection velocity in microns/sec
        , 'make_gradient' , 0 ...
        ...
        ...%%%%%%%% parameters for image generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        , 'box_size_px',    [2 2 0].^6 ...  	% size of the images.
        , 'psf_type', 'g' ...            	% only gaussian psf ('g') is currently supported
        , 'psf_sigma_um',   [0.4 0.4 0.7] ...  	% standard deviation of the psf in microns, indepedent for all three directions
        , 'renderer', 'points_from_nodes' ...  	%   'lines_from_bonds' or 'points_from_nodes'.
        ...
        , 'signal_level',      200 ...                %signal level above background
        , 'signal_background', 100 ...  % relative to signal at beads of 1.0
        , 'counting_noise_factor', 10 + 5*i ...		% counting noise  factor (noise = sqrt(o.counting_noise_factor*imageFinal).*randn(im_dims)  1.327
        , 'dk_background',     100 ...   % dark background average 189.462
        , 'dk_noise',          10 ...         % dark noise rms(std)%7.265
        ...
        , 'finer_grid' , 3 ... %%% to more accurately simulate bead position
        , 'store_x', 1 ...
        ...
        ...%%%%%%%% parameters for data analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        , 'corrTimeLimit', 5 ...
        , 'snr', NaN ...
        , 'Pe', NaN ...
        , 'num_runs', 5 ...
        );
    opt(i).Pe = dot(opt(i).u_convection,opt(i).psf_sigma_um)/opt(i).diff_coeff;
    opt(i).snr = opt(i).signal_level /...
        sqrt(opt(i).counting_noise_factor*opt(i).signal_background + opt(i).dk_noise*opt(i).dk_noise);
end

%% Run test
matlabpool open 4
K = 10;
num_mov = 1;
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
            fprintf('%s','.')
        end
        fit_opts = optimset('Jacobian','off','Display','off');
        %         tic
         
        [vector{j,k},o] = bead_test2_nobayes(opt(j));
%         disp(vector{j,k})
        %         toc
    end
    
    save('v_dot2_D_vary_nobayes')
    
end
matlabpool close

%% Parse the velocity fields
for j = 1:J
    for k = 1:K
        foo = vector{j,k};
        foo = foo{1};
        [L,M,I] = size(foo);
        for l = 1:L
            for m = 1:M
                conv_vx(j,k,l,m,1) = foo(l,m,2);
                conv_vy(j,k,l,m,1) = foo(l,m,1);
            end
        end
    end
end

%% Use quiver plot to visualize the fitted versus real velocities
for j = 1:J
%     for k = 1:K
        u = opt(j).u_convection;
        real_vx = u(1);
        real_vy = u(2);
        quiver(squeeze(mean(conv_vx(j,k,:,:),2)),squeeze(mean(conv_vy(j,k,:,:),2)),0);
        hold on
        quiver(ones(L,M)*real_vx,ones(L,M)*real_vy,0);
        hold off
        pause(1);
%     end
end

%% Plot parameters: real v. fitted
flat = @(x) x(:);

for j = 1:J
    u = opt(j).u_convection;
    vx(j) = mean(flat(conv_vx(j,:,:,:)));
    vx_std(j) = std(flat(conv_vx(j,:,:,:)),0);
    vy(j) = mean(flat(conv_vy(j,:,:,:)));
    vy_std(j) = std(flat(conv_vy(j,:,:,:)),0);
    real_vx(j) = u(1);
    real_vy(j) = u(2);
end

pe = [opt.Pe];

h1 = errorbar(pe,vx,vx_std,'b-')
hold on
plot(pe,real_vx,'r-')
xlabel('Pe')
ylabel('Fitted v_x (\mu m / sec)')
title('No Bayes. D = .1, SNR = 13')

figure
h2 = errorbar(pe,vy,vy_std,'b-')
hold on
plot(pe,real_vy,'r-')
xlabel('Pe')
ylabel('Fitted v_y (\mu m / sec)')
title('No Bayes. D = .01, SNR = 13')
