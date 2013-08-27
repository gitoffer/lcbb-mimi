function y = sort_pair_mean(x)
%SORT_PAIR_MEAN Sorts x, and finds the mean of consecutive term in sorted
%x.

x = sort(x);
y = (x(1:end-1) + x(2:end))/2;
