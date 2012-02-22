function dF = central_diff_multi(F, x, dim)
%CENTRAL_DIFF_MULTI
%
% xies@mit. Feb 2012.

switch nargin
    case 1
        x = 1;
        dim = 1;
    case 2
        dim = 1;
end

num_dims = ndims(F);
T = size(F,dim);
F = shiftdim(F,dim-1);
N = numel(F)/T;
correct_shape = size(F);
F = reshape(F,T,N);
dF = zeros(size(F));

for i = 1:N
    signal = F(:,i);
    X = 1:numel(signal);
    if numel(signal(~isnan(signal))) > 1
        signal = interp1(X(~isnan(signal)),signal(~isnan(signal)),X);
    end
    dF(:,i) = central_diff(signal,x);
end

dF = reshape(dF,correct_shape);
dF = shiftdim(dF,num_dims-(dim-1));

end