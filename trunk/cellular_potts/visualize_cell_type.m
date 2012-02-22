function types = visualize_cell_type(lattice,identity)

[N,M] = size(lattice);

types = zeros(N,M);
for i = 1:N
	for j = 1:M
		if lattice(i,j) > 0
			types(i,j) = identity(lattice(i,j));
		end
	end
end
