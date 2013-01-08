function [data,rows_left] = delete_nan_rows(data,dim,opt)
%DELETE_NAN_ROWS Returns the rows/cols from a matrix which are not all
%NaNs. (Alternatively, if you append an 'any' input, will delete rows which
%has ANY NaNs.
%
% USAGE: [data,rows_left] = delete_nan_rows(data,dim,'any'/'all')
%
% xies@mit.edu Aug 2012.

[n,m] = size(data);
if nargin < 3, opt = 'all'; end

switch dim
    case 2
        if strcmpi(opt,'all')
            row_idx = all(logical(isnan(data)),1);
        else
            row_idx = any(logical(isnan(data)),1);
        end
        data(:,row_idx) = [];
        row_idx = find(logical(row_idx));
        rows_left = setdiff(1:m,row_idx);
    case 1
        if strcmpi(opt,'all')
            row_idx = all(logical(isnan(data)),2);
        else
            row_idx = any(logical(isnan(data)),2);
        end
        data(row_idx,:) = [];
        row_idx = find(logical(row_idx));
        rows_left = setdiff(1:n,row_idx);
end

end