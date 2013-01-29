function [x o] = BD_simulator_PBC( varargin)


% interpret the input
o_base = struct( ...
    ...%%%%%%%% parameters for Brownian dynamics simulation %%%%%%%%%%%%%%%%
    'n_dims', 3 ...      %  number of dimensions in which the simulation is conducted  
    , 'sim_box_size_um',  [2 2 2].^10 * 0.0645 ...  % the simulated box is of this size. See code below for actual default value (should be box_size_px*um_per_px)
    , 'num_frames', 10 ...			% number of frames in the stack produced by the code
    , 'density', .1 ...              % density of the particles, in um^-o.n_dims
    , 'sec_per_frame', 5 ...		% seconds per frame
    ...
    , 'diff_coeff', 0.01 ...              	% diffusion coefficient in micron^2/sec
    , 'u_convection', [.1 0 0] ...        	% convection velocity in microns/sec
    , 'bonds_per_atom', 0 ...            	% # of bonds per atom
    , 'spring_const', 1 ...              	% spring constant 1/micron^2
    , 'topo', 'nn' ...               	% ('nn', 'random'). network topology nearest neighbor or random connections
    , 'make_gradient' , 0 ...  
    , 'ic', 'rand' ...               % initial conditions.  Leave at 'rand'.
    ...
    ...%%%%%%%% parameters for image generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ...
    , 'bleachType', 'none' ...       % bleaching is not implemented currently
    , 'bleachDecay', 0.1 ...         % bleaching is not implemented currently
    , 'finer_grid' , 3 ...         %%% to more accurately simulate bead position
    , 'store_x', 1 ...
);


o = merge_ops(varargin, o_base);

% set up the log structure


%% setup initial state of the simulation
N=round(o.density*prod(o.sim_box_size_um));
x0 = rand(N,3);
for i = 1:3
x0(:,i) = x0(:,i)*o.sim_box_size_um(i);
end

%% simulate the system 
fprintf(1,'Running Brownian dynamics simulation....  ')

sigma = sqrt(2*o.diff_coeff*o.sec_per_frame);

dx = randn(N,3,o.num_frames)*sigma ; % all the dx due to diffusion over history are generated

if any(o.u_convection~=0)
    for i = 1:3
    dx(:,i,:) = dx(:,i,:)+o.u_convection(i)*o.sec_per_frame; % update dx due to flow
    end
end

dx(:,:,1) = x0; % intial condition is applied

x = cumsum(dx,3); % integration over time
for i = 1:3
x(:,i,:) = mod(x(:,i,:),o.sim_box_size_um(i)); % periodic condition is applied
end


% figure
% for j = 1:1000
%     plot(x(:,1,j),x(:,2,j),'.')
%     F(j) = getframe;
% end

fprintf(1,'Simulation done, generating images....')

