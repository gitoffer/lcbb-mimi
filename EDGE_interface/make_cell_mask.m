function mask = make_cell_mask(m,frames,cellID,input)
%MAKE_CELL_MASK Make a BW mask of a cell based on a cell of interest.
% NOTE: This is very slow; I've found a better way of doing this.
%
% SYNOPSIS: mask = make_cell_mask(m,frames,sliceID,cellID,X,Y,um_per_px)
%
% INPUT: m - array of EDGE measurements
%        frames - frames of interest
%        sliceID - slice of interest
%        cellID - cell of interest
%        X/Y - dimensions of original image
%        um_per_px - microns per pixel ofimage
%
% OUTPUT: mask - binary mask of size [X,Y,numel(frames)]
%
% See also draw_measurement_on_cells, draw_measurement_on_cell_small
%
% xies@mit Dec 2011.

% if um_per_px not supplied, use 1
if ~isfield('input','um_per_px'), um_per_px = 1; end

% Extract relevant data from EDGEstack
vt_x = extract_msmt_data(m,'Vertex-x','off',input);
vt_y = extract_msmt_data(m,'Vertex-y','off',input);

vt_x = vt_x(frames,cellID);
vt_y = vt_y(frames,cellID);

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