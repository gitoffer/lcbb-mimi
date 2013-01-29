function adj = adjacency_matrix(neighborID,t)

num_cells = size(neighborID,2);

adj = nan(num_cells);

for i = 1:num_cells
    my_neighb = neighborID{t,i};
    if any(~isnan(my_neighb))
        adj(i,my_neighb) = 1;
    end
end

end
% figure,pcolor(adj); axis equal tight