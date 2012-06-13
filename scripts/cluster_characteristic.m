adj = adjacency_matrix(neighborID,1);
num_connection = numel(adj(~isnan(adj)));

peaks_neighbor = adjacency_matrix_binary(neighborID,1,peaks_hand);

for t = 1:num_frames
    this_adj = peaks_neighbor(:,:,t);
    pPA(t) = numel(this_adj(this_adj == 1))./num_connection;
    pAA(t) = numel(this_adj(this_adj == 0))./num_connection;
    pPP(t) = numel(this_adj(this_adj == 2))./num_connection;
end

plot(pPA),hold on,plot(pPP,'r-'),plot(pAA,'g-')

