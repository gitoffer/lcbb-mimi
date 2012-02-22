function mask = make_cell_mask(m,frames,sliceID,cellID,X,Y,um_per_px)
%MAKE_CELL_MASK Make a BW mask of a cell based on a cell of interest
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
% xies@mit Dec 2011.


if ~exist('um_per_px','var'), um_per_px = 1; end

vt_x = extract_msmt_data(m,'Vertex-x','off');
vt_y = extract_msmt_data(m,'Vertex-y','off');

vt_x = vt_x(frames,sliceID,cellID);
vt_y = vt_y(frames,sliceID,cellID);

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