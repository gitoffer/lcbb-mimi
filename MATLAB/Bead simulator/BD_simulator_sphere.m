function [x o] = BD_simulator_sphere(state, varargin)


% interpret the input
o_base = struct( ...
    ...%%%%%%%% parameters for Brownian dynamics simulation %%%%%%%%%%%%%%%%  
    'R_sphere',  3 ...  % um, the simulated box is of this size. See code below for actual default value (should be box_size_px*um_per_px),
    ,'sim_box_size_um',  [2^3.5 2^3.5 2^6] * 0.2 ...    
    , 'density',        2.5 ...              % density of the particles, in um^-o.n_dims
    , 'N', 69 ...                       % total number in sphere
    , 'int_cond', 'number' ...         % initialized with 'dentiy' or 'number', of particles in the sphere
    , 'um_per_px',      0.1 ...			% resolution, microns per pixel
    , 'sec_per_frame',  .000001 ...		% seconds per frame
    , 'num_frames',     1000000 ...			% number of frames in the stack produced by the code
    ...
    , 'diff_coeff',     20 ...              	% diffusion coefficient in micron^2/sec
    , 'u_convection',   [0 0 0] ...        	% convection velocity in microns/sec
    ...
    ...%%%%%%%% parameters for renderer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
);


o = merge_ops(varargin, o_base);

% set a new seed:
RandStream.setDefaultStream ... 
     (RandStream('mt19937ar','seed',sum(100*clock)));
defaultStream = RandStream.getDefaultStream;
savedState = defaultStream.State;
defaultStream.State = savedState;

%% setup initial state of the simulation
% generate postion of particles uniformly in a box of 2Rx2Rx2R in isze
int_cond = o.int_cond;

R = o.R_sphere;
if isempty(state) && strcmp(int_cond,'density')
    Ninbox=round(o.density*(2*R)^3);
    x0inbox = 2*R*rand(Ninbox,3)-R;
    insphere = sqrt(x0inbox(:,1).^2 + x0inbox(:,2).^2 + x0inbox(:,3).^2)<R;
    I = 1;
 
    x0 = zeros(sum(insphere),3);
    for i = 1 : numel(insphere)
        if insphere(i)==1
        x0(I,:) = x0inbox(i,:);
        I = I+1;
        end
    end
    N = size(x0,1);
elseif isempty(state) && strcmp(int_cond,'number')
    density = o.N/(4/3*pi*o.R_sphere)*1.2; % make more particle in the sphere and delete those more than needed.
    Ninbox=round(density*(2*R)^3);
    x0inbox = 2*R*rand(Ninbox,3)-R;
    insphere = sqrt(x0inbox(:,1).^2 + x0inbox(:,2).^2 + x0inbox(:,3).^2)<R;
    I = 1;
 
    x0 = zeros(sum(insphere),3);
    for i = 1 : numel(insphere)
        if insphere(i)==1
        x0(I,:) = x0inbox(i,:);
        I = I+1;
        end
    end
    x0 = x0(1:o.N,:);
    N = size(x0,1);
else
    x0=state;
    N = size(state,1);
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

% tic
% x = cumsum(dx,3); % integration over time
% toc

x = zeros(size(dx));
x(:,:,1) = dx(:,:,1);
for i = 2 :o.num_frames
    x(:,:,i)=x(:,:,i-1)+dx(:,:,i);
%     if mod(i,5)==0
        outsphere = sqrt(x(:,1,i).^2 + x(:,2,i).^2 + x(:,3,i).^2)>R;
        indout = find(outsphere);
        for j = 1:numel(indout)
            r = 0.95*R;
            theta = pi*rand;
            phi = 2*pi*rand;
            x(indout(j),1,i)=r*sin(theta)*cos(phi);
            x(indout(j),2,i)=r*sin(theta)*sin(phi);
            x(indout(j),3,i)=r*cos(theta);
        end
%     end
end



% figure
% for j = 1:1000
%     plot(x(:,1,j),x(:,2,j),'.')
%     F(j) = getframe;
% end

fprintf(1,'Simulation done, generating images....\n')

