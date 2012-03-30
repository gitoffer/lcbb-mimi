function [meas_n,ind] = neighbor_msmt(meas,neighborID)
%NEIGHBOR_MSMT Neighbor measurement

meas_n = cell(size(neighborID));

[~,num_cells] = size(neighborID);
ind = [];

for i = 1:num_cells
    if ~isnan(neighborID{i})
        meas_n{i} = meas(:,neighborID{i});
        ind = [ind i];
    else
        meas_n{i} = 0;
    end
end

end