function [x, E] = pwc_jumppenalty(y, square, gamma, display, maxiter)
% Performs PWC denoising of the input signal using least-squares or
% least-absolute (robust) forward jump penalization. It attempts to
% minimize the discrete functional:
%
%  E=||y-x||_p+gamma*||Dx||_0,
% 
% where ||.||_0 is the L0 norm, here used to count the number of jumps in x.
% The stopping criteria is at the first minima of H encountered.
%
% Usage:
% x = pwc_jumppenalty(y, square, gamma, maxiter)
%
% Input arguments:
% - y          Original signal to denoise of length N.
% - square     Set to 1 to perform least-squares fitting (p=2 in the global
%              functional), or 0 to perform least-absolute (robust) fitting
%              (p=1).
% - gamma      Positive regularization parameter.
% - display    (Optional) Set to 0 to turn off progress display, 1 to turn
%              on. If not specifed, defaults to progress display on.
% - maxiter    (Optional) Maximum number of iterations. If not specified,
%              defaults to 50.
%
% Output arguments:
% - x          Denoised output signal.
% - H          Global penalized functional value given the output signal.
%
% (c) Max Little, 2011. If you use this code for your research, please cite:
% M.A. Little, Nick S. Jones (2011)
% "Generalized Methods and Solvers for Noise Removal from Piecewise
% Constant Signals: Part II - New Methods"
% Proceedings of the Royal Society A (in press)

error(nargchk(3,5,nargin));
if (nargin < 4)
    display = 1;
end
if (nargin < 5)
    maxiter = 50;
end

y = y(:);
N = length(y);

r = zeros(0,1);             % Knot locations

Eold = Inf;

if (display)
    fprintf('Iter# Global functional\n');
end

% Iterate
iter = 1;
while (iter < maxiter)

    if (display)
        fprintf('%5d %7.2e\n',iter,Eold);
    end

    % Greedy scan for new knot location
    NLL = zeros(N,1);
    for i = 1:N
        
        % Append new location
        r1 = r;
        r1(end+1) = i;
        r1 = sort(r1);
        
        % Find optimum levels
        xtest = zeros(N,1);
        l = 1:(r1(1)-1);
        if (square)
            xtest(l) = mean(y(l));
        else
            xtest(l) = median(y(l));
        end
        for j = 2:iter
            l = r1(j-1):(r1(j)-1);
            if (square)
                xtest(l) = mean(y(l));
            else
                xtest(l) = median(y(l));
            end
        end
        l = r1(iter):N;
        if (square)
            xtest(l) = mean(y(l));
        else
            xtest(l) = median(y(l));
        end
        
        % Compute likelihood
        if (square)
            NLL(i) = 0.5*sum((xtest-y).^2);
        else
            NLL(i) = sum(abs(xtest-y));
        end
    end
    
    % Choose new location that minimizes the likelihood term
    [v,i] = min(NLL);
    
    % Add to knot locations
    r(end+1) = i;
    r = sort(r);

    % Re-compute solution at this iteration
    i = 1:(r(1)-1);
    xnew = zeros(N,1);
    if (square)
        xnew(i) = mean(y(i));
    else
        xnew(i) = median(y(i));
    end
    for j = 2:iter
        i = r(j-1):(r(j)-1);
        if (square)
            xnew(i) = mean(y(i));
        else
            xnew(i) = median(y(i));
        end
    end
    i = r(iter):N;
    if (square)
        xnew(i) = mean(y(i));
    else
        xnew(i) = median(y(i));
    end

    % Compute global functional value at current solution
    if (square)
        Enew = 0.5*sum((xnew-y).^2) + gamma*iter;
    else
        Enew = sum(abs(xnew-y)) + gamma*iter;
    end
    
    % Detect local minima in global functional
    if (Eold < Enew)
        if (display)
            fprintf('Converged in %d iterations\n', iter);
        end
        break;
    end
    
    Eold = Enew;
    iter = iter + 1;
end

if (display)
    if (iter == maxiter)
        fprintf('Maximum iterations exceeded\n');
    end
end

x = xnew;
E = Enew;
