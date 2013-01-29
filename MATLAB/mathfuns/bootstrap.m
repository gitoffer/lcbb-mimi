function [bootstat,varargout] = bootstrap(data,nboot,statfun,dim)
%BOOTSTRAP_RANDOM Randomply permute a given dimension of a matrix as a way
%of bootstrapping.
%
% SYNOPSIS: [shuffled_data] = bootstrap_random(data,dim);
%
% Might deprecate due to bootstrp.m
% xies@mit.edu April 2012.

% Check inputs
if nargin < 3, error('Not enough inputs.');
else
    if nargin == 3, dim = 1; end
end

% Make the dimension of interest the leading dimension
data = shiftdim(data,dim-1);
p = ndims(data);
ndata = size(data,1);

% Preallocate if we're exporting the actual bootstrapped data/indices
export = nargout > 1;
if export
    new_indices = zeros(nboot,ndata);
    shuffled_data = zeros([nboot,size(data)]);
end

bootstat = nan(nboot,1);

for i = 1:nboot
    
    if export % Shuffle data
        new_indices(i,:) = randperm(ndata);
        shuffled_data(i,:,:) = data(new_indices,:,:,:,:);
        try bootstat(i) = feval(statfun,shuffled_data(i,:,:));
        catch err
            display(err);
            keyboard
        end
    else
        new_indices = randperm(ndata);
        shuffled_data = data(new_indices,:,:,:,:,:);
        try bootstat(i) = feval(statfun,shuffled_data);
        catch err
            display(err);
            keyboard
        end
    end
    
end
% Put dimensions back the way it was
shuffled_data = shiftdim(shuffled_data,p-(dim-1));

end