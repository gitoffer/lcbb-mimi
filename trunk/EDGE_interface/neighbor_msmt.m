function meas_n = neighbor_msmt(meas,neighborID)

meas_n = cell(1,numel(neighborID));

for i = 1:numel(neighborID)
    if ~isnan(neighborID{i})
        meas_n{i} = meas(:,neighborID{i});
    else
        meas_n{i} = 0;
    end
end
