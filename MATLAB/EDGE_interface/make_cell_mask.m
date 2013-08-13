function mask = make_cell_mask(cells,frames,stackID,input)
%MAKE_CELL_MASK Make a BW mask of a cell based on a cell of interest.
% NOTE: This is very slow; I've found a better way of doing this.
%
% SYNOPSIS: mask = make_cell_mask(cells,frames,stackID,input)
%
% INPUT: cells - array of CellObj
%        frames - frames of interest
%        stackID - cell of interest
%        input - input info
%
% OUTPUT: mask - binary mask of size [X,Y,numel(frames)]
%
% See also draw_measurement_on_cells, draw_measurement_on_cell_patch
%
% xies@mit Dec 2011.

% if um_per_px not supplied, use 1
if ~isfield('input','um_per_px'), um_per_px = 1; end

% Extract relevant data from cellobj
vt_x = cat(2,cells.get_stackID(stackID).vertex_x);
vt_y = cat(2,cells.get_stackID(stackID).vertex_y);

vt_x = vt_x(frames,:);
vt_y = vt_y(frames,:);

% Construct mask
X = input.X; Y = input.Y;
mask = zeros(Y,X,numel(frames));
for i = 1:numel(frames)
    x = vt_x{i}./um_per_px;
    y = vt_y{i}./um_per_px;
    if ~any(isnan(x))
        mask(:,:,i) = poly2mask(x,y,Y,X);
    end
end
mask = logical(mask);

end