function revID = reverse_index(ID)

revID = zeros(size(ID));
for i = 1:numel(ID)
    revID(i) = find(ID == i);
end