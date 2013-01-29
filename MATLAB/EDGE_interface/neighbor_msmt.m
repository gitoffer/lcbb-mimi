function [meas_n,ind] = neighbor_msmt(meas,neighborID,t)
%NEIGHBOR_MSMT Given a measurement matrix (time x cells) and a cell-array
% of the cellIDs of neighbors of each focal cells, return a cell-array of
% the neighbor-measurements arranged by the focal cells.
%
% SYNOPSIS: [neighbor_measurement,focal_ind] = 
%               neighbor_msmt(measurement,neighborID);
% INPUT: measurement - an array (Time-by-Cells)
%        neighborID - a cell array (Time-by-Cells) where each element
%                     corresponds to the cellID of a cell at a single frame
% OUTPUT: neighbor_measurement - a cell array (Time-by-Cells) where each
%                     element corresponds is a (Time-by-num_neighbors)
%                     array. Focal cells without neighbors are given a
%                     measurement of 0.
%
% xies@mit.edu April 2012.

if nargin < 3, t = 1;end

[~,num_cells] = size(neighborID);
meas_n = cell(1,num_cells);
ind = [];

for i = 1:num_cells
    if ~isnan(neighborID{1,i})
        % if there are neighbors, put them into matrix
        meas_n{i} = meas(:,neighborID{t,i});
        % 
        ind = [ind i];
    else
        % if there are no neighbors, pad with 0
        meas_n{i} = 0;
    end
end

end