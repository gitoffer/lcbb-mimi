function I = find_nearest_nonan(x,start)
%FIND_NEAREST_NONAN
%
% USAGE: ind = find_nearest_nonan(x,start)

if ~isvector(x),error('Input should be a vector.'); end

N = numel(x);
log = isnan(x);
[~,I] = min( abs( (1:N)'.*~log - start ) );

end