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
old_fit = zeros(size(y));
curve = y;

% Initialize
[height,max] = extrema(curve);
guess = [height(1) x(max(1)) x(3)-x(1)]; % initial guesss
significant = 1;
S_null = sum(curve.^2);
resnorm_old = sum(curve.^2);
heights = []; peaks = []; vars = [];
parameters = [];

n_peaks = 0;
% Suppress display
opt = optimset('Display','off');

% While significant by F-test, fit 1 more gaussian
while significant

    p = lsqcurvefit(@lsq_gauss1d,guess,x,curve,lb,ub,opt);
    this_fit = lsq_gauss1d(p,x);
    
    residual = this_fit + old_fit - y;
    resnorm = norm(residual);
    
    n_peaks = n_peaks + 1;
%     S_alt = resnorm/(T-3*(n_peaks));
%     test_obs = S_alt/S_null;
    F = ((resnorm_old - resnorm)/3)/(resnorm/(T-(n_peaks*3+1)));
    
    Fcrit = finv(alpha,3,T-(n_peaks)*3-1);
%     P = fcdf(test_obs,T-(n_peaks)*3,T-(n_peaks-1)*3);
%     if P < alpha
    if F >= Fcrit
        % Collect the "significant" parameters
%         parameters(1,n_peaks) = p(1);
%         parameters(2,n_peaks) = p(2);
%         parameters(3,n_peaks) = p(3);
        heights = [heights p(1)];
        peaks = [peaks p(2)];
        vars = [vars p(3)];
        
        % Update the statistics
        significant = 1;
%         S_null = S_alt;
%         n_peaks = n_peaks + 1;
        resnorm_old = resnorm;
        old_fit = old_fit + this_fit;
        
        % The new 'curve to fit' is the residual
%         residual(residual>0) = 0;
        curve = -residual;
        [height,max] = extrema(curve);
        guess = [height(1) x(max(1)) x(3)-x(1)];
        
    else
        significant = 0;
    end
    
end

parameters(1,:) = heights;
parameters(2,:) = peaks;
parameters(3,:) = vars;

end