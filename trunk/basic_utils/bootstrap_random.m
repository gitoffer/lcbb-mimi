function [shuffled_data,new_indices] = bootstrap_random(data,dim)
%BOOTSTRAP_RANDOM Randomply permute a given dimension of a matrix as a way
%of bootstrapping.
%
% SYNOPSIS: [shuffled_data] = bootstrap_random(data,dim);
%
% xies@mit.edu April 2012.

% Make the dimension of interest the leading dimension
data = shiftdim(data,dim-1);
D = ndims(data);
ndata = size(data,1);

% Shuffle data
new_indices = randperm(ndata);
shuffled_data = data(new_indices,:,:,:,:);

% Put dimensions back the way it was
shuffled_data = shiftdim(shuffled_data,D-(dim-1));

end