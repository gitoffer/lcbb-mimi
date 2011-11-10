function [a a_err logs stats] = gauss2d_fit(f, varargin)

o = struct('n_drop', 0      ... % drop this many highest f(x,y) values. Based on code by D.Kolin and P. Wiseman.
    , 'mc_steps', 10^4 ...  % number of Monte Carlo steps to take in estimating the uncertainties
    , 'crop_peak_domain', 'crop_peak_domain_top_90_percent' ...
    , 'mc_test_steps', 100 ...
    , 'max_step_size_iters', 10 ...
    , 'step_size_step_size', 0.5 ...
    , 'a0', [] ...
    );
o = merge_ops(varargin, o);

% takes an f(y,x,t) 3-d stack of images and attempts to fit Gaussians to
% every xy slice.  Returns an array of parameter fits,
% a(i,:) = [a1, .., a5], where
% f(x,y) = a1*exp(- ( (x - a4)^2 + (y-a5)^2)/a2^2) + a3 + noise


% pre allocate space
a = zeros(size(f,3),5) * NaN;

% calculate the x and y grids

N = size(f);
if length(N) < 3
    N(3) = 1;
end

[X Y] = meshgrid(1:N(2), 1:N(1));

f = reshape(f,N(1)*N(2),numel(f)/N(1)/N(2));


    function w = weight(b)
        w = (ft - shifted_gaussian(x,y,b))./std(ft);
    end


for t = 1:N(3)
    ft = f(:,t);
    x = X(:);
    y = Y(:);
    
    % it's important to crop the domain before discarding peak values
    % since this preserves the integrity of the data (i.e. the size of the
    % data is recoverable.
    [ft,x,y] = feval(o.crop_peak_domain, ft,x,y);
    
    % drop the top o.values
    fcutoff = max(ft);
    for i = 2:o.n_drop
        fcutoff = max(ft(ft < fcutoff));
    end
    %
    i = ft < fcutoff;
    ft = ft(i);
    x = x(i);
    y = y(i);
    % scale the function value so that the abs value of a(1) is comparable
    % to image size to improve convergence
    
    scale = mean(ft)/mean(N(1:2));
    ft = ft./scale;
    
    
    if isempty(ft)
        a(t,:) = NaN*ones(1,5);
        continue;
    end
    %
    % fminsearch (simplex) works just fine for nice peaks, but for bad ones
    % the peak center parameters tend to drift way beyond the image
    % boundaries. This produces enormous velocities. This necessiates a
    % bounded optimization, such as that provided by lsqnonlin of the
    % MATLAB optimization toolbox.
    % K.T.
    
    % Ideas for speeding this up
    % 1. Introdue periodic BCs or a prior in the weight function and
    % revert to the fasteer simplex method.
    % 2. Introduce
    
    P.solver = 'lsqnonlin';
    P.objective = @weight;
    P.lb = [0           0               0       1           1       ];
    P.x0 = [mean(ft)    1               0       x(argmax(ft))     y(argmax(ft)) ];
    P.ub = [max(ft)     mean(N(1:2))    max(ft) N(1)        N(2)    ];
    
    if i > 1  % this seems to slow down the executionlsq
        % use the previous values as guesses for current one
        ao = a(t-1,:);
        ifinite = isfinite(ao);
        P.x0(ifinite) = ao(ifinite);
    end
    P.options =optimset('Display', 'none', 'tolx', 1e-5, 'tolfun', 1);
    
    a(t,:) = feval(P.solver, P);
    % ---------------------------------------------------------------------
    % Uncertainty estimation
    % ---------------------------------------------------------------------
    % estimate the uncertainty in the fit parameters based on the assumption of independent,
    % homogeneous, normal pixel noise
    
    if nargout > 1
        a_err = zeros(N(3),5) * NaN;
        step_size = 0.01;
        
        beta = 0.5/var(ft - shifted_gaussian(x, y, a(t,:)));
        
        for trials = 1:o.max_step_size_iters
            ss = step_size*a(t,:);
            % the a(t,3) is often zero, so an appropriate step size should
            % be scaled by the a(t,1)
            ss(3) = ss(1);
            [logs stats] = mc_int( @(b) sum((ft - shifted_gaussian(x,y,b)).^2)*beta ...
                ,  a(t,:) ...
                , ss ...
                , o.mc_test_steps ...
                , @(b) b ...
                );
            
            
            % check if decent acceptance ratio has been achieved
            if stats.acceptance_ratio > 0.1
                % do a sampling run
                [logs stats] = mc_int( @(b) sum((ft - shifted_gaussian(x,y,b)).^2)*beta ...
                    ,  a(t,:) ...
                    , ss ...
                    , o.mc_steps ...
                    , @(b) b ...
                    );
                break;
            else
                % if not, halve the step size and repeat
                step_size = step_size/2;
            end
        end
        
        % calculate the uncertainty estimates
        if size(logs.obs, 1) < 3
            a_err(t,:) = zeros(size(a(t,:)));
        else
            a_err(t,:) = std(logs.obs);
        end
        a_err(t,[1 3]) = a_err(t,[1 3])*scale;
    end
    % ---------------------------------------------------------------------
    
    % rescale the magnitude of the data
    a(t,[1 3]) = a(t,[1 3])*scale;
end
end










