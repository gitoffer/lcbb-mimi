close all
clear all
addpath('./simulator')
%% paramters for simulation
o = struct( ...
    ...%%%%%%%% parameters for Brownian dynamics simulation %%%%%%%%%%%%%%%%
    'n_dims', 2 ...      %  number of dimensions in which the simulation is conducted  
    , 'sim_box_size_um',  [2 2 2].^9 * 0.0645 ...  % the simulated box is of this size. See code below for actual default value (should be box_size_px*um_per_px)
    , 'num_frames',     500 ...			% number of frames in the stack produced by the code
    , 'density',        10 ...              % density of the particles, in um^-o.n_dims
    , 'um_per_px',      0.0645 ...			% resolution, microns per pixel
    , 'sec_per_frame',  .01 ...		% seconds per frame
    ...
    , 'diff_coeff',     3 ...              	% diffusion coefficient in micron^2/sec
    , 'u_convection',   [10 0 0] ...        	% convection velocity in microns/sec
    ...
    ...%%%%%%%% parameters for image generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    , 'box_size_px',    [2 2 2].^7 ...  	% size of the images.
    , 'psf_type', 'g' ...            	% only gaussian psf ('g') is currently supported
    , 'psf_sigma_um',   [0.3 0.3 0.7] ...  	% standard deviation of the psf in microns, indepedent for all three directions
    , 'renderer', 'points_from_nodes' ...  	%   'lines_from_bonds' or 'points_from_nodes'.
    ...
    , 'signal_level',      100 ...                %signal level above background
    , 'signal_background', 0 ...  % relative to signal at beads of 1.0
    , 'counting_noise_factor', 1. ...		% counting noise  factor (noise = sqrt(o.counting_noise_factor*imageFinal).*randn(im_dims)  1.327
    , 'dk_background',     0 ...   % dark background average 189.462 
    , 'dk_noise',          0 ...         % dark noise rms(std)%7.265
    ...
    , 'finer_grid' , 5 ... %%% to more accurately simulate bead position
    ...
    ...%%%%%%%% parameters for data analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    , 'corrTimeLimit', 10 ...
    , 'num_runs', 5 ...
);



%% run beads simulation and generate images

w = o.psf_sigma_um(1);

num_mov = 16

o1 = o;
o1.diff_coeff = 0.05;
o1.u_convection(1) = 0;
o2 = o;
o2.diff_coeff = 2;
o2.u_convection(1) = 0;
clear im1 im2
for i = 1: num_mov
    [logs1 ] = BD_simul8tr( [],o1);
    [im1{i} ] = image_generator(logs1,o1);
    while any(isnan(im1{i}))
        [logs1 ] = BD_simul8tr( [],o1);
        [im1{i} ] = image_generator(logs1,o1);
    end
    [logs2 ] = BD_simul8tr( [],o2);
    [im2{i} ] = image_generator(logs2,o2);
    while any(isnan(im2{i}))
        [logs2 ] = BD_simul8tr( [],o2);
        [im2{i} ] = image_generator(logs2,o2);
    end
end
clear logs1 logs2