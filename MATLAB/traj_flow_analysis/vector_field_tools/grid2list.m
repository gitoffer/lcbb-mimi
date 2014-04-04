function list = grid2list(X,Y)

if ndims(X) > 2 || ndims(Y) > 2, error('Need 2 dimensional inputs.'); end
if numel(X) ~= numel(Y), error('Two arguments must be vectors of the same length.'); end

foo = interleave(X,Y);
n = numel(foo);
X = foo(1:2:n-1);
Y = foo(2:2:n);

list = cat(2,X,Y);