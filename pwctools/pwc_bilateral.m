function x = pwc_bilateral(y, soft, beta, width, display, stoptol, maxiter)
% Performs PWC denoising of the input signal using hard or soft kernel
% bilateral filtering.
%
% Usage:
% x = pwc_bilateral(y, soft, beta, width, display, stoptol, maxiter)
%
% Input arguments:
% - y          Original signal to denoise of length N.
% - soft       Set this to 1 to use the soft Gaussian kernel, else uses
%              the hard kernel.
% - beta       Kernel parameter. If soft Gaussian kernel, then this is the
%              precision parameter. If hard kernel, this is the kernel
%              support.
% - width      Spatial kernel width W.
% - display    (Optional) Set to 0 to turn off progress display, 1 to turn
%              on. If not specifed, defaults to progress display on.
% - stoptol    (Optional) Precision of estimate as determined by square
%              magnitude of the change in the solution. If not specified,
%              defaults to 1e-3.
% - maxiter    (Optional) Maximum number of iterations. If not specified,
%              defaults to 50.
%
% Output arguments:
% - x          Denoised output signal.
%
% (c) Max Little, 2011. If you use this code for your research, please cite:
% M.A. Little, Nick S. Jones (2011)
% "Generalized Methods and Solvers for Noise Removal from Piecewise
% Constant Signals: Part I - Background Theory"
% Proceedings of the Royal Society A (in press)

error(nargchk(4,7,nargin));
if (nargin < 5)
    display = 1;
end
if (nargin < 6)
    stoptol = 1e-3;
end
if (nargin < 7)
    maxiter = 50;
end

y = y(:);
N = size(y,1);

% Construct bilateral sequence kernel
w = zeros(N,N);
j = 1:N;
for i = 1:N
    w(i,:) = (abs(i-j) <= width);
end

xold = y;           % Initial guess using input signal
d = zeros(N,N);

if (display)
    if (soft)
        fprintf('Soft kernel\n');
    else
        fprintf('Hard kernel\n');
    end
    fprintf('Kernel parameters beta=%7.2e, W=%7.2e\n', beta, width);
    fprintf('Iter# Change\n');
end

% Iterate
iter = 1;
gap = Inf;
while (iter < maxiter)

    if (display)
        fprintf('%5d %7.2e\n',iter,gap);
    end
    
    % Compute pairwise distances between all samples
    for i = 1:N
        d(:,i) = 0.5*(xold-xold(i)).^2;
    end
    
    % Compute kernels
    if (soft)
        W = exp(-beta*d).*w;    % Gaussian (soft) kernel
    else
        W = (d <= beta^2).*w;    % Characteristic (hard) kernel
    end

    % Do kernel weighted mean shift update step
    xnew = sum(W'*xold,2)./sum(W,2);

    gap = sum((xold - xnew).^2);
    
    % Check for convergence
    if (gap < stoptol)
        if (display)
            fprintf('Converged in %d iterations\n', iter);
        end
        break;
    end
    
    xold = xnew;
    iter = iter + 1;
end

if (display)
    if (iter == maxiter)
        fprintf('Maximum iterations exceeded\n');
    end
end

x = xnew;
