function dup_idx = find_duplicates(x)
%FIND_DUPLICATES Returns the indices of entries in x which have duplicated
%values (returns ALL indices).
%
% dup_idx = find_duplicates(x)
%
% xies@mit.edu

[~,I,J] = unique(x,'first');
duplicate_values = x(find( ~ismember(1:numel(x),I) ));
dup_idx = find( ismember(x,duplicate_values));

end