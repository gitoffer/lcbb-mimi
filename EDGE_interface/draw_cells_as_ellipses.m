function draw_cells_as_ellipses(m,zID)
%DRAW_CELLS_AS_ELLIPSES Draws cells roughly as fitted ellipses and colorize
%by XY anisotropy.
%
% SYNOPSIS: draw_cells_as_ellipses(m,zID)
%
% INPUT: m - stack of EDGE measurements


if ~exist('zID','var')
    zID = 1;
end

try
    centroid_x(:,:) = extract_msmt_data(m,'centroid-x');
    centroid_y(:,:) = extract_msmt_data(m,'centroid-y');
    lx(:,:) = extract_msmt_data(m,'major axis')./3;
    ly(:,:) = extract_msmt_data(m,'minor axis')./3;
    orientation(:,:) = deg2rad(extract_msmt_data(m,'orientation'));
    anis(:,:) = extract_msmt_data(m,'anisotropy-xy');
catch err
    throw(err);
end
min_anis = .5;
max_anis = 2;

data = cat(3,centroid_x,centroid_y,lx,ly,orientation,anis);
data = squeeze(data(zID,:,:));

for i = 1:size(data,1)
    this_cell = data(i,:);
    if any(isnan(this_cell))
        continue
    else
        color = find_color(this_cell(6),min_anis,max_anis);
        ellipse(this_cell(3),this_cell(4),this_cell(1),this_cell(2),this_cell(5),...
            color);
        hold on
        axis([20 180 20 100]);
        axis equal
    end
end
caxis([min_anis max_anis])
colorbar
hold off