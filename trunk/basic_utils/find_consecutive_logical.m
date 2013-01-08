function counts = find_consecutive_logical(X,dim)
%FIND_CONSECUTIVE_LOGICALS Given a logical matrix input, will calculate the
% number of consecutive 1's including and up to each matrix element. Will
% assume that the dimension of counting is the first dimension unless
% otherwise supplied.
%
% SYNOPSIS: counts = find_consecutive_logicals(X)
%           counts = find_consecutive_logicals(X,dim)
%
% Taken from Roger Stafford,
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/160813
% xies@mit. March 2012.

if ndims(X) > 2, error('Dimensions greater than 2 not supported.'); end

if nargin < 2, dim = 1; end

if dim == 1, X = X'; end

n_cols = size(X,1);
% Pad first column with zeros (for diff)
padded = [zeros(1,n_cols);X.'];
% Flatten array
padded = padded(:);
% Find all the zeros
zero_indices = find(~padded);
padded(zero_indices) = [0;1-diff(zero_indices)];
counts = reshape(cumsum(padded),[],n_cols).';
counts(:,1) = [];

if dim == 1, counts = counts'; end

end