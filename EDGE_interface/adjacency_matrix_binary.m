function adj = adjacency_matrix_binary(neighborID,t,binary_measurement)

[num_frames,num_cells] = size(neighborID);

adj = nan(num_cells,num_cells,num_frames);

for k = 1:num_frames
    for i = 1:num_cells
        this_neighbor = neighborID{t,i};
        if ~isnan(this_neighbor)
            adj(i,this_neighbor,k) = binary_measurement(k,this_neighbor);
            adj(i,this_neighbor,k) = adj(i,this_neighbor,k) + binary_measurement(k,i);
        end
        
    end
end