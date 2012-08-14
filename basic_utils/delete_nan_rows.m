function [data,rows_left] = delete_nan_rows(data,dim)
%DELETE_NAN_ROWS Returns the rows/cols from a matrix which are not all
%NaNs.
%
% xies@mit.edu Aug 2012.

[n,m] = size(data);

switch dim
    case 2
        row_idx = all(isnan(data),1);
        data(:,row_idx) = [];
        row_idx = find(logical(row_idx));
        rows_left = setdiff(1:m,row_idx);
    case 1
        row_idx = find(all(isnan(data),2));
        data(row_idx,:) = [];
        row_idx = find(logical(row_idx));
        rows_left = setdiff(1:n,row_idx);
end

end