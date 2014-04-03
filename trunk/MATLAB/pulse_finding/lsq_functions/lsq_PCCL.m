function y = lsq_PCCL(params,x,split_index)
%LSQ_PCLM Construct piecewise continuous constant-linear model, given the
% input data, X, and time of splitting. To be used with Optimization
% Toolbox.
%
% USAGE: params = fit_PCCL(y,x);
%
% INPUT: params - array of parameters, (1) constant term
%                                      (2) slope of line
%        x - input data
%        split_x - index at which the model splits from constant to linear
%
% OUTPUT: y - fit
%
% See also: LSQCURVEFIT
% 
% xies@mit.edu

if split_index >= numel(x) || split_index <= 1
    error('Splitting point out of range!');
end

split_x = x(split_index);

a = params(1);
m = params(2);
b = a - m*split_x;

y = zeros(size(x));
y(1:split_index) = a;
y(split_index + 1:end) = m*x(split_index + 1:end) + b;

if iscolumn(x), ensure_column(x); end

end