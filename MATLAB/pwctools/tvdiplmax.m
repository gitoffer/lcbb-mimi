function lambdamax = tvdiplmax(y)
% Calculate the value of lambda so that if lambda >= lambdamax, the TVD
% functional solved by TVDIP is minimized by the trivial constant
% solution x = mean(y). This can then be used to determine a useful range
% of values of lambda, for example.
%
% Usage:
% lambdamax = tvdiplmax(y)
%
% Input arguments:
% - y          Original signal to denoise, size N x 1.
%
% Output arguments:
% - lambdamax  Value of at which x = mean(y) is the output of the TVDIP
%              function.
%
% (c) Max Little, 2011. If you use this code for your research, please cite:
% M.A. Little, Nick S. Jones (2011)
% "Generalized Methods and Solvers for Noise Removal from Piecewise
% Constant Signals: Part I - Background Theory"
% Proceedings of the Royal Society A (in press)

error(nargchk(1,1,nargin));
y = y(:);
N = length(y);
M = N - 1;

% Construct sparse operator matrices
I1 = speye(M,M);
O1 = spalloc(M,1,M);
D = [I1 O1]-[O1 I1];

DDT = D*D';
Dy  = D*y;

lambdamax = max(abs(DDT\Dy));
