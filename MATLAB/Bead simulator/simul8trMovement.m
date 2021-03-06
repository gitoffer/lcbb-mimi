function [state, logs] = simul8trMovement(state,o,logs)
% Simulates particle diffusion and flow, given a 2D matrix, inputObjects
% (containing only 0, 1, 2, etc) and diffCoeff, state.u_convection(1),state.u_convection(2)
% Does not support multiple states -- call a new simul8trMovement separately,
% and pass it the inputObjects matrix of a different state

% August 30, 2004
% By DK

% Do different kinds of particle movement here
%
% All calculations are performed assuming units (length, time, energy) = (micrometers, seconds,
% k_BT)
%

% ------------------------
% set up some short cuts
% ------------------------

D = o.diff_coeff;

L = o.sim_box_size_um;

data_size = size(state.x);


k = state.spring_const*o.n_dims;
if D > 0
    k = k*D;
else
    %    warning('%s: Performing a perverse BD simulation with zero diffusion coefficient, but finite time scale. \n\n', mfilename);
end

% For better integration stability reduce the
% integration step size for the spring forces
% So that dt << 1/k.  However, we expect
% spring_const * |x| ~ 1 if all goes well, therefore
% the more appropriate measure of stiffness is
% n_dims * D
if isfinite(k) && sum(state.nbonds) > 0
    dt = o.time_step_max_kD/abs(k);
    n_steps = ceil(o.sec_per_frame/dt);
    dt = o.sec_per_frame/n_steps;

else
    k = 0;
    dt = o.sec_per_frame;
    n_steps = 1;
end

dt = o.sec_per_frame;
k = k*dt;
sigma = sqrt(2*D*dt);


for istep = 1:n_steps
% %     % bonds
% %     if sum(state.nbonds) > 0
% % 
% %         for dim = 1:o.n_dims
% % 
% %             % calculate the distances
% %             for ibond = 1:size(state.bonds,2)
% %                 dx{dim}(:,ibond) = state.x(state.bonds(:,ibond), dim) - state.x(:,dim);
% %                 dx{dim}(:,ibond) = dx{dim}(:,ibond) - L(dim)*round(dx{dim}(:,ibond)/L(dim));
% %             end
% % 
% %             state.x(:,dim) = state.x(:,dim) +  k*sum(dx{dim},2);
% %         end
% % 
% %     end
    
    % Brownian motion
    state.x = state.x + randn(data_size)*sigma;

end

% % if sum(state.nbonds) > 0
% % 
% %     % calculate the root-mean-squared bond length and record it
% %     % create bond pair indices
% %     B1 = [];
% %     B2 = [];
% % 
% %     for icol = 1:size(state.bonds, 2);
% %         B1 = [B1; (1:size(state.bonds,1))'];
% %         B2 = [B2; state.bonds(:,icol)];
% %     end
% % 
% %     % make the index pairs unique
% %     i = (B1 < B2);
% %     B1 = B1(i);
% %     B2 = B2(i);
% %     r = state.x(B1, :) -state.x(B2, :);
% %     for dim = 1:o.n_dims
% %         r(:,dim) = r(:,dim) - L(dim)*round(r(:,dim)/L(dim));
% %     end
% %     logs.mean_bond_length(end+1) = sqrt(mean(sum( r.^2,2)));
% % end

% ----------------------
% Convection
% ----------------------

for dim = 1:o.n_dims
    state.x(:,dim)...
        = ...
        state.x(:,dim) + o.u_convection(dim)*o.sec_per_frame;
end

% -----------------------------
% Periodic boundary conditions
% -----------------------------
%
% Shift x into [0, L)
%
if ~o.make_gradient
    for dim = 1:o.n_dims
        state.x(:,dim) = mod(state.x(:,dim), L(dim));

    end
else
    dim = 1;
    i = (state.x(:, dim) > L(dim));
    % bounce all the particles that crossed the wall at x = L
    state.x(i,dim) = 2*L(dim) - state.x(i,dim);
    % wrap all the particles that passed the wall at 0
    state.x(~i,dim) = mod(state.x(~i,dim),  L(dim));

    % apply periodic BCs to all the rest
    for dim = 2:o.n_dims
        state.x(:,dim) = mod(state.x(:,dim), L(dim));
    end
end


end

