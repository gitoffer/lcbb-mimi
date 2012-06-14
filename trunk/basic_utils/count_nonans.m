function nonnans = count_nans(x)

x = x(:);
nonnans = numel(x(~isnan(x)));

end