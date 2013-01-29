function cell = draw_random_cell(lattice)

[N,M] = size(lattice);

draw = 1;
% while draw
    n = randi(N);
    m = randi(M);
%     if lattice(n,m) == 0
%         draw = 1;
%     else
%         draw = 0;
%     end
% end
cell.i = n;
cell.j = m;