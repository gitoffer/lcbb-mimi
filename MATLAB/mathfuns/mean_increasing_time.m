function tau_dist = mean_increasing_time(rate,dim)

if ndims(rate) > 2, error('Dimensions greater than 2 not supported.'); end

if nargin < 2, dim = 1; end

if dim == 1, rate = rate'; end

n_cols = size(rate,1);
padded = [zeros(1,n_cols);rate.'];
padded = padded(:);
zero_indices = find(~padded);
padded(zero_indices) = [0; 1-diff(zero_indices)];
% counts = reshape(cumsum(padded),[],n_cols).';
% counts(:,1) = [];

tau_dist = abs(padded(padded < 0));

end