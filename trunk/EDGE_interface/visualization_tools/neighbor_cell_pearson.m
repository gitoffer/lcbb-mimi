function pearsons = neighbor_cell_pearson(meas_cell,meas_neighb,focal_cells,neighborID,handle)
%NEIGHBOR_CELL_PEARSON Calculate the Pearson's correlation between a set of
% focal_cells and their neighbors for any given measurement made on the
% embryo. e.g. constriction rate, myosin accumulation rate, etc.
% Optionally, draw the 1-neighbor corona and the correlation on the embryo.
% 
% INPUT: meas_cell - the measurement
%        meas_neighb - cell array of the measurement made on neighbors,
%           indexed by the focal cell
%        focal_cells - index of focal cells
%        neighborID - cell array of indeces of neighor cells
%(optional) handle - if defined, will display movie. Required structure
%                    fields:
%                       vertex-x, vertex-y, savename
% To JUST display the correlations
%
% xies@mit.edu March 2012


if nargin == 5, display = 1; else display = 0; end
num_frames = size(meas_cell,1);

num_foci = numel(focal_cells);
pearsons = cell(1,num_foci);
for j = 1:num_foci
    % get j-th focal cell information
    focal_cell = focal_cells(j);
    neighbor_cells = neighborID{1,focal_cell};
    focal_cell_meas = meas_cell(:,focal_cell);
    
    % calculate neighbor correlations
    neighbor_corrcoef = nan(1,1+numel(neighbor_cells));
    for i = 1:numel(neighbor_cells)
        neighbor_cell_meas = meas_neighb{focal_cell}(:,i);
        neighbor_corrcoef(i+1) = nan_pearsoncorr(neighbor_cell_meas,focal_cell_meas);
    end
    neighbor_corrcoef(1) = NaN;
    
    % Plot as movie
    if display
        handle.todraw = [focal_cell neighbor_cells'];
        handle.m = neighbor_corrcoef(ones(1,num_frames),:);
        handle.title = ['Pearson''s correlation between cell #' num2str(focal_cell) ' and its neighbors'];
        F = draw_measurement_on_cell_small(handle);
        movie2avi(F,[handle.savename num2str(focal_cell)]);
    end
    pearsons{j} = neighbor_corrcoef(2:end);
    
end