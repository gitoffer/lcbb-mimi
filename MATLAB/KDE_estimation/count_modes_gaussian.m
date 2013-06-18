function num_modes = count_modes_gaussian(h,data,bins)
%COUNT_MODES_GAUSSIAN Counts the number of zero crossings in a Gaussian
% derivative KDE of data.
% USAGE: num_modes = count_modes_gaussian(h,data,bins)
%
% xies@mit.edu

ind = crossing( gaussian_derivative(h,data,bins) );
num_modes = numel(ind);

end
