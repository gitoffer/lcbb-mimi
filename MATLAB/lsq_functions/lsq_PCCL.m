function y = lsq_PCCL(params,x,split_x)
%LSQ_PCLM Construct piecewise continuous constant-linear model, given the
% input data, X, and time of splitting. To be used with Optimization
% Toolbox.
%
% USAGE: params = fit_PCCL(y,x);
%
% INPUT: params - array of parameters, (1) constant term
%                                      (2) slope of line
%                                      (3) intercept of line
%        x - input data
%        split_x - x at which the model splits from constant to linear
%            NB: this is not the index of splitting point
%
% OUTPUT: y - fit
%
% See also: LSQCURVEFIT
% 
% xies@mit.edu

split_index = findnearest(x,split_x);

if split_index => numel(x) || split_index <= 1
    error('Splitting point out of range!');
end

a = params(1);
m = params(2);
b = params(3);

y = zeros(size(x));

y(1:split_index) = constant;
y(split_index + 1:end) = m*x(split_index + 1:end) + b;

if iscolumn(x), ensure_column(x); end

end