function cells = edge2cell(embryo_stack)
%EDGE2CELL
%
% USAGE: cells = edge2cell(embryo_stack);
% 
% xies@mit.edu Feb 2013.

num_cells = [embryo_stack.num_cell];
num_cells_padded = cumsum([0 num_cells]);

% [cells(1:sum(num_cells)).embryoID] = deal([]);
measurements = setdiff(fieldnames(embryo_stack), ...
    {'input','dev_time','dev_frame','num_cell'});

for i = 1:sum(num_cells)
    
    % Collect the indices
    stackID = i;
    embryoID = find( (num_cells_padded - i) < 0, 1, 'last');
    cellID = i - num_cells_padded(embryoID);
    
    this_cell.embryoID = embryoID;
    this_cell.stackID = stackID;
    this_cell.cellID = cellID;
    
    % Get input structure
%     input = embryo_stack(embryoID).input;
    
    % Put the relevant measurements into the cell structure
    for j = 1:numel(measurements)
        % Extract single measurement for this cell
        meas_this_cell = embryo_stack(embryoID).(measurements{j})(:,cellID);
        % Try to make into numeric array
        try cell2mat(meas_this_cell);
        catch err
        end

        this_cell.(measurements{j}) = ...
            meas_this_cell;
    end
    
    % Collect the time
    this_cell.dev_time = embryo_stack(embryoID).dev_time;
    
    cells(i) = CellObj(this_cell);
    
end

end
