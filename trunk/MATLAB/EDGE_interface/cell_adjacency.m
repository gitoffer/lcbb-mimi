function cellAdj = cell_adjacency(neighborID)
%CELL_ADJACENCY Generate an adjacency matrix from neighborID
% EDGE output.
%
% xies@mit.edu Oct 2013
%

[T,N] = size(neighborID);
cellAdj = zeros(N,N,T); % 3D sparse matrix not supported

for t = 1:T
	for i = 1:N
	
		this_neighborID = neighborID{t,i};

		if isnan(this_neighborID), continue; end

		cellAdj(i,this_neighborID(this_neighborID > 0),t) = 1;

	end
end

end
