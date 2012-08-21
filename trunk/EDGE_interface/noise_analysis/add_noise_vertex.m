function [delta_area,new_area] = add_noise_vertex(vx,vy,noise_level)

if any(size(vx) ~= size(vy)), error('Size of vertices must be the same.'); end
% N = size(vx);

old_area = get_cell_area(vx,vy);

% Add random noise to vertex positions

vx = round(vx + randn(size(vx))*noise_level);
vy = round(vy + randn(size(vy))*noise_level);

new_area = get_cell_area(vx,vy);

delta_area = new_area - old_area;
delta_area = delta_area/old_area;

end