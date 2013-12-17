function [parameters,varargout] = iterative_gaussian_fit(y,x,alpha,lb,ub,bg)
%ITERATIVE_GAUSSIAN_FIT Uses LSQCURVEFIT to fit multiple Gaussians to a 1D
% signal. Will use F-test to penalize for over-fitting. If BG is turned on,
% will fit an exponential background.
%
% params = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub,BG)
% [p,resnorm] = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub,BG)
% [p,resnorm,J] = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub,BG)
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
% [A center width]
guess = [height(1);x(max(1));x(3)-x(1)];

% Initialize
if background
    significant = 1;
    resnorm_old = sum(y.^2);
    guess_bg = [1;100;0]; % [A, lambda, offset]
    
    n_peaks = 0;
    % Negative
    LB = cat(2,[0;0;lb(3)],lb); % lower bounds for ALL params
    UB = cat(2,[nanmax(y);nanmax(y);ub(3)],ub); % upper bounds for ALL params
    guess = cat(2,guess_bg,guess); % concatenate bg and peak guesses

else
    significant = 1;
    resnorm_old = sum(y.^2);
    n_peaks = 0; LB = lb; UB = ub;
end

% While significant by F-test, fit 1 more gaussian
while significant
    
    if background
        [p,resnorm,residual,~,~,~,J] = ...
            lsqcurvefit(@synthesize_gaussians_withbg,guess,x,y,LB,UB,opt);
    else
        [p,resnorm,residual,~,~,~,J] = ...
            lsqcurvefit(@synthesize_gaussians,guess,x,y,LB,UB,opt);
    end

%     [p,residual,J,covB,resnorm] = nlinfit(x,y,@synthesize_gaussians_withbg,guess);
    
    n_peaks = n_peaks + 1;
    
    F = ((resnorm_old-resnorm)/3) ...
        /(resnorm/(T-n_peaks*3-1+3));
    %     F = (resnorm/(T-n_peaks*3))/(resnorm_old/(T-n_peaks*3-3))
    Fcrit = finv(1-alpha,3,T-n_peaks*3-1+3);
    %     P = fcdf(F,T-n_peaks*3-3,T-n_peaks*3)
    
    if F >= Fcrit
        %     if P < alpha
        % Collect the "significant" parameters
        parameters = p;
        Jacob = J;
        
        % Updapte the statistics
        significant = 1;
        resnorm_old = resnorm;
        
        % Update the constraints
        LB = cat(2,LB,lb);
        UB = cat(2,UB,ub);
        
        % Guess the new n+1 peak parameters from the residuals
        [height,max] = extrema(-residual);
        if numel(height) > 0
            % update guess with current params and next guess
            guess = cat(2,p,[height(1);x(max(1));x(3)-x(1)]);
        else
            significant = 0;
            break
        end
        
    else
        significant = 0;
    end
    
end

% Final test against background-only model

guess_bg = [1;30;x(1)];
p_bg = lsqcurvefit(@lsq_exponential,guess_bg,x,y,[0 -inf 0],[inf inf inf],opt);
residuals = lsq_exponential(p_bg,x) - y;
resnorm_bg = sum(residuals.^2);
% F-Test
F_bg = ((resnorm_bg-resnorm)/(3*n_peaks)) ...
    /(resnorm/(T-n_peaks*3 -1 +3));
Fcrit = finv(1-alpha,3*n_peaks,T-n_peaks*3-1+3);
if F_bg < Fcrit
    parameters = p_bg;
    Jacob = [];
end

if nargout > 1, varargout{1} = residuals; end
if nargout > 2, varargout{2} = Jacob;
if ~exist('parameters','var'), parameters = []; end

end
