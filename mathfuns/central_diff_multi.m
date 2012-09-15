function dF = central_diff_multi(F, x, dim)
%CENTRAL_DIFF_MULTI Wrapper for central_diff, where the input F can have
%multiple dimensions.
%
% USE: dF = central_diff_multi(F,x,dim);
%
% xies@mit. Feb 2012.

switch nargin
    case 1
        x = 1;
        dim = 1;
    case 2
        dim = 1;
end

% Make sure the dimension of differentiation is the first
num_dims = ndims(F);
T = size(F,dim);
F = shiftdim(F,dim-1);
N = numel(F)/T;
correct_shape = size(F);
F = reshape(F,T,N);
dF = zeros(size(F));

%Loop through dimensions
for i = 1:N
    signal = F(:,i);
    X = 1:numel(signal);
    if numel(signal(~isnan(signal))) > 5
        signal = interp1(X(~isnan(signal)),signal(~isnan(signal)),X);
    end
    dF(:,i) = central_diff(signal,x);
end

% Put the correct dimension back in place
dF = reshape(dF,correct_shape);
dF = shiftdim(dF,num_dims-(dim-1));

end