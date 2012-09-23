function parameters = iterative_gaussian_fit(y,x,alpha,lb,ub,bg)
%ITERATIVE_GAUSSIAN_FIT Uses LSQCURVEFIT to fit multiple Gaussians to a 1D
% signal. Will use F-test to penalize for over-fitting. If BG is turned on,
% will fit an exponential background.
%
% params = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub,BG)
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

if ~exist('bg','var'), bg = 'off'; end

if strcmpi(bg,'on')
    background = 1;
else
    background = 0;
end

T = length(y);

% Suppress display
opt = optimset('Display','off');

% Initial guess
[height,max] = extrema(y);
guess = [height(1);x(max(1));x(3)-x(1)];

% Initialize
if background
    significant = 1;
    guess_bg = [1;x(1);30];
    parameters = lsqcurvefit(@lsq_exponential,guess_bg,x,y,[0 -Inf 0],[Inf Inf Inf],opt);
    residuals = lsq_exponential(parameters,x) - y;
    resnorm_old = sum(residuals.^2);
    
    n_peaks = 0;
    LB = cat(2,[0;-Inf;0],lb);
    UB = cat(2,[Inf;Inf;Inf],ub);
    guess = cat(2,guess_bg,guess);
%     keyboard
else
    significant = 1;
    resnorm_old = sum(y.^2);
    n_peaks = 0; LB = lb; UB = ub;
end

% While significant by F-test, fit 1 more gaussian
while significant
    
    if background
        [p,resnorm,residual] = lsqcurvefit(@synthesize_gaussians_withbg,guess,x,y,LB,UB,opt);
    else
        [p,resnorm,residual] = lsqcurvefit(@synthesize_gaussians,guess,x,y,LB,UB,opt);
    end
    
    %     this_fit = synthesize_gaussians(p,x);
    
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