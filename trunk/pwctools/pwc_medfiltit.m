function xnew = pwc_medfiltit(y, W)
% Performs running median filtering, iterated until convergence, using
% window of size W. Requires MEDFILT1 from the Matlab signal processing
% toolbox.
%
% Usage:
% x = pwc_medfiltit(y, W)
%
% Input arguments:
% - y          Original signal to denoise.
% - W          Median filter window size, should be positive and odd.
%
% Output arguments:
% - x          Denoised output signal.
%
% (c) Max Little, 2011. If you use this code for your research, please cite:
% M.A. Little, Nick S. Jones (2011)
% "Generalized Methods and Solvers for Noise Removal from Piecewise
% Constant Signals: Part I - Background Theory"
% Proceedings of the Royal Society A (in press)

error(nargchk(2,2,nargin));

y = y(:);

xold = y; % Initialize iterated running medians

% Iterate
stop = false;
iter = 0;
while (~stop)
    xnew = medfilt1(xold,W);
    stop = all(xnew == xold);
    xold = xnew;
    iter = iter + 1;
end
