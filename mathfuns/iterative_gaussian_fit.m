function parameters = iterative_gaussian_fit(curve,x,alpha,lb,ub)
%ITERATIVE_GAUSSIAN_FIT Uses LSQCURVEFIT to fit multiple Gaussians to a 1D
%signal. Will use F-test to penalize for over-fitting.
%
% params = iterative_gaussian_fit(ydata,xdata,alpha,lb,ub)
%
% See also: LSQCURVEFIT, LSQ_GAUSS1D
%
% xies@mit. Feb 2012.

if numel(x) ~= numel(curve)
    error('The input vector and the input curve should have the same dimensions');
end

switch nargin
    case 2
        alpha = 0.1; lb = []; ub = [];
    case 3
        lb = []; ub = [];
end

T = length(curve);

[height,max] = extrema(curve);
guess = [height(1) max(1) 2]; % initial guesss
significant = 1;
S_null = Inf;
heights = []; peaks = []; vars = [];
n_peaks = 0;
% Suppress display
opt = optimset('Display','off');

% While significant by F-test, fit 1 more gaussian
while significant

    [p,resnorm,residual] = lsqcurvefit(@lsq_gauss1d,guess,x,curve,lb,ub,opt);
    S_alt = resnorm/(T-2*(n_peaks+1));
    test_obs = S_alt/S_null;
    
    P = fcdf(test_obs,T-(n_peaks+1)*3,T-n_peaks*3);
    if P < alpha && any(residual < 0)
        % The new 'curve to fit' is the rectified residual
        residual(residual>0) = 0;
        curve = -residual;
        [height,max] = extrema(curve);
        guess = [height(1) max(1) 2];
        heights = [heights p(1)];
        peaks = [peaks p(2)];
        vars = [vars p(3)];
        significant = 1;
        S_null = S_alt;
        n_peaks = n_peaks + 1;
    else
        significant = 0;
    end
    
end
% Collect output terms
parameters(1,:) = heights(:);
parameters(2,:) = peaks(:);
parameters(3,:) = vars(:);