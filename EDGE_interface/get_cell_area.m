function area = get_cell_area(vx,vy)

if any(size(vx) ~= size(vy)), error('Size of vertices must be the same.'); end

% N = size(x); % number of vertices

% Make bounding box
% min_vx = min(vx);
max_vx = max(vx);
% min_vy = min(vy);
max_vy = max(vy);

bounding_box = [max_vx + 1, max_vy + 1];

mask = poly2mask(vx,bvy,bounding_box);

area = numel(mask(logical(mask)));

end