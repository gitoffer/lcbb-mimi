function mask = make_cell_mask(cellobj,frames,input)
%MAKE_CELL_MASK Make a BW mask of a CellObj using POLY2MASK.
%
% SYNOPSIS: mask = make_cell_mask(cells,frames,stackID,input)
%
% INPUT: cellobj - one CellObj
%        frames - frames of interest
%        input - input info
%
% OUTPUT: mask - binary mask of size [X,Y,numel(frames)]
%
% See also draw_measurement_on_cells, draw_measurement_on_cell_patch
%
% xies@mit Dec 2011.

% check inputs
if numel(cellobj) > 1
	error('MAKE_CELL_MASK needs a single CellObj.');
end

% if um_per_px not supplied, use 1
if ~isfield('input','um_per_px'), um_per_px = 1; end

% get vertex coordinates
vt_x = cellobj.vertex_x; vt_y = cellobj.vertex_y;
% extract frames of interest
vt_x = vt_x(frames,:); vt_y = vt_y(frames,:);

% Construct mask with POLY2MASK
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
