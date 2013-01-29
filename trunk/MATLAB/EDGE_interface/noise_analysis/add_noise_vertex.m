function [delta_area,new_area] = add_noise_vertex(vx,vy,noise_level,num_vert)

switch nargin
    case 3
        num_vert = 1;
    otherwise
end

if any(size(vx) ~= size(vy)), error('Size of vertices must be the same.'); end
% N = size(vx);

old_area = get_cell_area(vx,vy);

% Add random noise to vertex positions
which = zeros(size(vx));
which(randi(numel(vx),num_vert)) = 1;

vx = round(vx + randn(size(vx)).*which*noise_level);
vy = round(vy + randn(size(vy)).*which*noise_level);

new_area = get_cell_area(vx,vy);

delta_area = new_area - old_area;
delta_area = delta_area/old_area;

end