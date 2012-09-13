function parameters = iterative_gaussian_fit(y,x,alpha,lb,ub)
%ITERATIVE_GAUSSIAN_FIT Uses LSQCURVEFIT to fit multiple Gaussians to a 1D
%signal. Will use F-test to penalize for over-fitting.
%
% params = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub)
%
% See also: LSQCURVEFIT, LSQ_GAUSS1D
%
% xies@mit. Feb 2012.

if numel(x) ~= numel(y)
    error('The input vector and the input curve should have the same dimensions');
end

switch nargin
    case 2
        alpha = 0.1; lb = []; ub = [];
    case 3
        lb = []; ub = [];
end

T = length(y);

% Initial guess
[height,max] = extrema(y);
guess = [height(1);x(max(1));x(3)-x(1)];

% Initialize
significant = 1;
resnorm_old = sum(y.^2);
n_peaks = 0; LB = lb; UB = ub;
% heights = []; peaks = []; vars = [];

% Suppress display
opt = optimset('Display','off');

% While significant by F-test, fit 1 more gaussian
while significant
    
    [p,resnorm,residual] = lsqcurvefit(@synthesize_gaussians,guess,x,y,LB,UB,opt);
    this_fit = synthesize_gaussians(p,x);
    
    n_peaks = n_peaks + 1;
    
    F = ((resnorm_old-resnorm)/3)/(resnorm/(T-n_peaks*3-1));
%     F = (resnorm/(T-n_peaks*3))/(resnorm_old/(T-n_peaks*3-3))
    Fcrit = finv(1-alpha,3,T-n_peaks*3-1);
%     P = fcdf(F,T-n_peaks*3-3,T-n_peaks*3)

    if F >= Fcrit
%     if P < alpha
        % Collect the "significant" parameters
        parameters = p;
        
        % Updapte the statistics
        significant = 1;
        resnorm_old = resnorm;
        
        % Update the constraints
        LB = cat(2,LB,lb);
        UB = cat(2,UB,ub);
        
        
        % Guess the new n+1 peak parameters from the residuals
        [height,max] = extrema(-residual);
        if numel(height) > 0
            guess = cat(2,guess,[height(1);x(max(1));x(3)-x(1)]);
        else
            significant = 0;
            break
        end
        
    else
        significant = 0;
    end
    
end

if ~exist('parameters','var'), parameters = []; end

end