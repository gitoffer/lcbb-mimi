function [x, E] = pwc_tvdrobust(y, lambda, display, stoptol, maxiter)
% Performs robust discrete total variation denoising (TVD) using interior-
% point linear programming. It minimizes the following discrete functional:
%
%  E=||y-x||_1+lambda*||Dx||_1,
%
% over the variable x, given the input signal y, according to the value
% of the regularization parameter lambda >= 0. D is the first
% difference matrix.
%
% Usage:
% [x, E] = pwc_tvdrobust(y, lambda, display, stoptol, maxiter)
%
% Input arguments:
% - y          Original signal to denoise.
% - lambda     The non-negative regularization parameter.
% - display    (Optional) Set to 0 to turn off progress display, 1 to turn
%              on. If not specifed, defaults to progress display on.
% - stoptol    (Optional) Precision as determined by duality gap tolerance,
%              if not specified, defaults to 1e-5.
% - maxiter    (Optional) Maximum interior-point iterations, if not
%              specified defaults to 60.
%
% Output arguments:
% - x          Denoised output signal.
% - E          Objective functional at minimum.
%
% (c) Max Little, 2011. If you use this code for your research, please cite:
% M.A. Little, Nick S. Jones (2011)
% "Generalized Methods and Solvers for Noise Removal from Piecewise
% Constant Signals: Part II - New Methods"
% Proceedings of the Royal Society A (in press)

error(nargchk(2,5,nargin));
if (nargin < 3)
    display = 1;
end
if (nargin < 4)
    stoptol = 1e-5;
end
if (nargin < 5)
    maxiter = 60;
end

y = y(:);
N = length(y);

% Construct sparse operator matrices
I1 = speye(N);
O1 = spalloc(N,1,N);
D = [I1 O1]-[O1 I1];
D = D(:,1:N);
D(N,N) = 0;

if (display)
    fprintf('Solving for lambda=%5.2e\nIter# Gap\n', ...
        lambda);
end

% Set up robust TVD as L1-regression problem
A = [speye(N); -lambda*D];
b = [y; spalloc(N,1,N)];

% Minimize robust TV functional using interior-point linear programming.
M = size(A,1);
u = ones(M,1);
a = 0.5*u;
x = -lp_fnm(A', -b', A'*a, u, a, stoptol, maxiter, display)';
E = sum(abs(y-x)) + lambda*sum(abs(diff(x)));

% Solves a linear program by the interior-point method:
% min(c * u), s.t. A * x = b and 0 < x < u
% Based on code originally written by Daniel Morillo, Roger Koenker, and
% Paul Eilers, 1999-2004.
function y = lp_fnm(A, c, b, u, x, stopgap, stopit, display)

% Set some constants
beta = 0.9995;
[m n] = size(A);

% Generate inital feasible point
s = u - x;
y = (A' \  c')';
r = c - y * A;
r = r + 0.001 * (r == 0);
z = r .* (r > 0);
w = z - r;
gap = c * x - y * b + w * u;

% Interior-point iteration loop
it = 0;
while ((gap > stopgap) && (it < stopit))

    it = it + 1;
    
    % Compute affine step
    q = 1 ./ (z' ./ x + w' ./ s);
    r = z - w;
    Q = spdiags(sqrt(q), 0, n, n);
    AQ = A * Q;          % PE 2004
    rhs = Q * r';        % "
    dy = (AQ' \ rhs)';   % "
    dx = q .* (dy * A - r)';
    ds = -dx;
    dz = -z .* (1 + dx ./ x)';
    dw = -w .* (1 + ds ./ s)';
    
    % Compute maximum allowable step lengths
    fx = bound(x, dx);
    fs = bound(s, ds);
    fw = bound(w, dw);
    fz = bound(z, dz);
    fp = min(fx, fs);
    fd = min(fw, fz);
    fp = min(min(beta * fp), 1);
    fd = min(min(beta * fd), 1);
    
    % If full step is feasible, take it. Otherwise modify it
    if (min(fp, fd) < 1)
        
        % Update mu
        mu = z * x + w * s;
        g = (z + fd * dz) * (x + fp * dx) + (w + fd * dw) * (s + fp * ds);
        mu = mu * (g / mu) ^3 / ( 2* n);
        
        % Compute modified step
        dxdz = dx .* dz';
        dsdw = ds .* dw';
        xinv = 1 ./ x;
        sinv = 1 ./ s;
        xi = mu * (xinv - sinv);
        rhs = rhs + Q * (dxdz - dsdw - xi);
        dy = (AQ' \ rhs)';
        dx = q .* (A' * dy' + xi - r' -dxdz + dsdw);
        ds = -dx;
        dz = mu * xinv' - z - xinv' .* z .* dx' - dxdz';
        dw = mu * sinv' - w - sinv' .* w .* ds' - dsdw';
        
        % Compute maximum allowable step lengths
        fx = bound(x, dx);
        fs = bound(s, ds);
        fw = bound(w, dw);
        fz = bound(z, dz);
        fp = min(fx, fs);
        fd = min(fw, fz);
        fp = min(min(beta * fp), 1);
        fd = min(min(beta * fd), 1);
        
    end
    
    % Take the step
    x = x + fp * dx;
    s = s + fp * ds;
    y = y + fd * dy;
    w = w + fd * dw;
    z = z + fd * dz;
    gap = c * x - y * b + w * u;
    if (display)
        fprintf('%5d %7.2e\n', it, gap);
    end
end

% Fill vector with allowed step lengths.
function b = bound(x, dx)
b = 1e20 + 0 * x;
f = find(dx < 0);
b(f) = -x(f) ./ dx(f);
