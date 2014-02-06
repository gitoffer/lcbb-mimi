function I = find_nearest_nonan(x,start)
%FIND_NEAREST_NONAN
%
% USAGE: ind = find_nearest_nonan(x,start)

if ~isvector(x),error('Input should be a vector.'); end

N = numel(x);
y = (1:N)'.*~isnan(x) - start;
% y( y < 0 ) = Inf;
[~,I] = min(abs(y));

end