function x = pwc_cluster(y, K, soft, beta, biased, display, stoptol, maxiter)
% Performs PWC denoising of the input signal using hard or soft mean-shift,
% K-means, or likelihood mean shift clustering.
%
% Usage:
% x = pwc_cluster(y, K, soft, beta, biased, display, stoptol, maxiter)
%
% Input arguments:
% - y          Original signal to denoise of length N.
% - K          Number of PWC levels (clusters). If K<N, performs K-means
%              clustering. Choose K=[] or K=N to perform mean-shift.
% - soft       Set this to 1 to use the soft Gaussian kernel, else uses
%              the hard kernel.
% - beta       Kernel parameter. If soft Gaussian kernel, then this is the
%              precision parameter. If hard kernel, this is the kernel
%              support.
% - biased     Set this to 1 to use 'biased' mode: that is, the weighted
%              mean of the input samples, rather than the current estimated
%              PWC signal. Note that if performing K-means, this is
%              automatically 1.
% - display    (Optional) Set to 0 to turn off progress display, 1 to turn
%              on. If not specifed, defaults to progress display on.
% - stoptol    (Optional) Precision of estimate as determined by square
%              magnitude of the change in the solution. If not specified,
%              defaults to 1e-5.
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

error(nargchk(5,8,nargin));
if (nargin < 6)
    display = 1;
end
if (nargin < 7)
    stoptol = 1e-5;
end
if (nargin < 8)
    maxiter = 50;
end

y = y(:);

N = size(y,1);

if (isempty(K))
    K = N;
    if (display)
        fprintf('Mean-shift mode\n');
    end
else
    if (display)
        fprintf('K-means mode K=%d\n', K);
    end
end

if (K < N)
    biased = 1;
    xold = randsample(y,K);     % Random cluster centroids
else
    xold = y;                   % Initialise to input signal
end

if (display)
    if (soft)
        fprintf('Soft kernel\n');
    else
        fprintf('Hard kernel\n');
    end
    fprintf('Kernel parameter beta=%7.2e\n', beta);
    if (biased)
        fprintf('Biased (likelihood) mode\n');
    else
        fprintf('Unbiased mode\n');
    end
    fprintf('Iter# Change\n');
end

d = zeros(N,K);

if (K < N)
    I = eye(K);                 % Indicators for cluster centroids
end

% Iterate
iter = 1;
gap = Inf;
while (iter < maxiter)

    if (display)
        fprintf('%5d %7.2e\n',iter,gap);
    end

    % Compute pairwise distances
    if (K < N)
        % Distances between cluster centroids and input samples
        for i = 1:K
            d(:,i) = 0.5*(y-xold(i)).^2;
        end
    else
        % Distances between current estimated PWC samples
        for i = 1:N
            d(:,i) = 0.5*(xold-xold(i)).^2;
        end
    end
    
    % Compute kernels
    if (soft)
        % Soft Gaussian kernel
        W = exp(-beta*d);
        if (K < N)
            % Soft cluster assignment kernel
            W = W./repmat(sum(W,2),1,K);
        end
    else
        if (K == N)
            % Hard characteristic kernel
            W = (d <= beta^2);
        else
            % Hard cluster indicator kernel
            [v,i] = min(d,[],2);
            W = I(i,:);
        end
    end
    
    % Normalize kernel to find mean weights
    w = 1./sum(W,2);

	% Kernel weighted update step
    if (biased)
        xnew = (W'*(w.*y))./(W'*w);
    else
        xnew = (W'*(w.*xold))./(W'*w);
    end

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

if (K < N)
    % Assign samples to nearest cluster centroids when K < N
    for i = 1:K
        d(:,i) = abs(y-xnew(i)).^2;
    end
    [v,i] = min(d,[],2);
    x = xnew(i);
else
    x = xnew;
end
