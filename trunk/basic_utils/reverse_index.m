function revID = reverse_index(ID)
%REVERSE_INDEX
%
% SYNOPSIS: rev_ind = reverse_index(ind)
% If B = A(ind), then A = B(rev_ind);
% xies@mit.edu

revID = nan(1,max(ID));

for i = 1:numel(revID)
    try revID(i) = find(ID == i);
    end
end

end