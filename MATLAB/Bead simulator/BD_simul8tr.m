function [logs state o] = simul8tr(state, varargin)
% function [image state o logs] = simul8tr(state, varargin)
% Purpose:
% Simulate and network of Brownian particles connected by springs
% as viewed through a microscope.
%
% Input:
%   all input is optional. Code will run as simul8tr([]), carrying out the
%   default simulation.
%
%   state -- population structure generated by the code.  Use an empty array
%   for most runs. Use the structure output by the code to restart a
%   simulation.
%   optional struct of simulation options --  See code below for interpretation of
%   the options.  Default values are supplied for all options and used for
%   any option that is left out.
%
% Output:
%   postConv -- an (y,x,time) array of simulated microscope images
%   state    -- a struct containing the state of the system, to be used for
%               restarts
%   o       -- all the options used in the simulations, including all the
%   defaults and user
%   logs -- logs currently pre-convolution images (i.e. plain plots of the
%   nodes and bonds) if the debug option is set to 1 as well as a plot of
%   ensemble mean bond length at every iteration.
%
% Example:
% [postConv state o logs] = simul8tr(state, varargin)
%   This runs a single frame simulation of Brownian particles
% Based on original code by David Kolin and Paul Wiseman of McGill
% University.
%
% Kirill Titievsky
% kir@mit.edu
%
%
% -


% interpret the input
o_base = struct( ...
    ...%%%%%%%% parameters for Brownian dynamics simulation %%%%%%%%%%%%%%%%
    'n_dims', 3 ...      %  number of dimensions in which the simulation is conducted  
    , 'sim_box_size_um',  [2 2 2].^10 * 0.0645 ...  % the simulated box is of this size. See code below for actual default value (should be box_size_px*um_per_px)
    , 'num_frames', 10 ...			% number of frames in the stack produced by the code
    , 'density', .1 ...              % density of the particles, in um^-o.n_dims
    , 'sec_per_frame', 5 ...		% seconds per frame
    ...
    , 'diff_coeff', 0.001 ...              	% diffusion coefficient in micron^2/sec
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
logs.x = [];


%% setup initial state of the simulation
if isempty(state)
    % Sets up "state" structure
    for i=1:size(o.density,2)
        
        n_atoms(i) = round( ...
              prod(o.sim_box_size_um(1:o.n_dims)) ...
            * o.density(i) ...
            );
        
        % positions are stored in a matrix x(atom,dimension)
        if strcmp(o.ic, 'rand')
            state(i).x = rand(n_atoms(i), o.n_dims)*diag(o.sim_box_size_um(1:o.n_dims));
        end
        
% %         state(i).qYield = ones(n_atoms(i), 1).*o.qYield(i);
% %         state(i).blink = ones(n_atoms(i), o.num_frames);
% %         state(i).numToBleach(1) = 0;
        
        % -----------------------------------------------------------------
        % bonds
        % -----------------------------------------------------------------
        %
        % create a symmetric connection matrix:
        %   Initialize data structures:
        %   bonds(i,:) is a row vector of indices of atom indices to which
        %   i is bonded: i.e. (i,j) in B <=> j in bond(i,1:nbonds(i)).
        %   nbonds(i) is the length of the bond list that is stored
        %   explicitly since the number of elements in all rows of bonds must be the
        %   same to take advantage of MATLAB's matrices.
        %
        state(i).bonds = zeros(n_atoms(i)*o.bonds_per_atom(i),2);
        state(i).spring_const =o.spring_const(i);
        
        nbonds = zeros(n_atoms(i),1);
        bonds = zeros(n_atoms(i), o.bonds_per_atom(i));
        if o.bonds_per_atom(i) > 0
            
            % first fill the bond table with bonds to self
            %  bonds(i,:) == i : This is a convenient initial value since
            %  the harmonic bond force corresponding to padding element is by
            %  definition 0.
            for ibond = 1:size(bonds, 2)
                bonds(:,ibond) = 1:n_atoms(i);
            end
            if strcmp(o.topo, 'rand')
                % perfectly random connections among atoms
                for ii = 1:n_atoms(i)
                    for jj = (ii+1):n_atoms(i)
                        if nbonds(ii) < o.bonds_per_atom(i)
                            nbonds([ii jj]) = nbonds([ii jj]) + 1;
                            bonds(ii, nbonds(ii)) = jj;
                            bonds(jj, nbonds(jj)) = ii;
                        else
                            break;
                        end
                    end
                end
            elseif strcmp(o.topo, 'nn')
                % fill the bond table with the nearest neighbors, in order
                %   compute the distance matrix
                %   calculate the sort order
                D = zeros(n_atoms(i));
                for dim = 1:o.n_dims
                    X = meshgrid(state(i).x(:,dim));
                    X = X'-X;
                    
                    % apply the periodic boundary conditions
                    X = X-round(X/L(dim))*L(dim);
                    
                    % convert it to distance
                    D = D + X.^2;
                end
                
                for atom = 1:(n_atoms(i)-1)
                    % sort the distances between atom i and all others in
                    % increasing order
                    [bla, nni] = sort( D(atom, (atom+1):end));
                    nni = nni + atom;
                    % nni (nearest neighbor indices) now is the list of atom indices closest to atom
                    % from this list we remove nni < atom
                    nni(nni < atom) = [];
                    % now remove the candidate neighbors that have no available
                    % valences
                    nni(nbonds(nni) == o.bonds_per_atom) = [];
                    
                    n_bonds_needed = o.bonds_per_atom - nbonds(atom);
                    nni = nni(1:min(length(nni), n_bonds_needed));
                    % now create the bonds
                    for btom = nni
                        nbonds([atom btom]) =  nbonds([atom btom]) + 1;
                        bonds(atom, nbonds(atom)) = btom;
                        bonds(btom, nbonds(btom)) = atom;
                    end
                end
            end
        end
        state(i).bonds = bonds;
        state(i).nbonds = nbonds;     
    end
end

%% simulate the system 
% fprintf(1,'Running Brownian dynamics simulation....  ')
logs.x = zeros([size(state.x),o.num_frames]);
for t = 1:o.num_frames;       
        % update particle positions
        [state logs] = simul8trMovement(state,o, logs);

        logs.x(:,:,t) = state.x; % Store the coordinates in matrix logs.x (particle, dim, time)
end

% fprintf(1,'Simulation done, generating images....')

end
