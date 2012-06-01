function [data,rows_left] = delete_nan_rows(data,dim)

[n,m] = size(data);

switch dim
    case 2
        row_idx = all(isnan(data),1);
        data(:,row_idx) = [];
        rows_left = setdiff(1:m,row_idx);
    case 1
        row_idx = find(all(isnan(data),2));
        data(row_idx,:) = [];
        rows_left = setdiff(1:n,row_idx);
end

end