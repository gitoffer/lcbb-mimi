function merges = find_merges(correspondence)
%FIND_MERGES Given a certain CORRESPONDENCE (index of mapping) from a set
% of objects, S_A, and another set of objects, S_B, return the members in
% set S_A which map onto the same object in S_B.
%
% USAGE: merges = find_merges(correspondence)
%
% INPUT: correspondence - Index of mapping from S_A to S_B. 0 and NaN
%                         indicate no mapping.
% OUTPUT: merges.origin - objects in S_A that were merged
%         merges.target - the object in S_B that the merged objects from
%                         .origin all correspond to
% xies@mit.edu

% Get rid of the non-mapped ones (0)
correspondence(correspondence == 0) = NaN;

% sort and take the derivative to find the same values
[sorted_corr,I] = sort(correspondence);
% I = reverse_index(I);
duplicates = find(diff(sorted_corr) == 0);
duplicates = unique([duplicates duplicates+1]); % boundary correction

% Get a merged-target list
merger_targets = unique(correspondence(I(duplicates)));
merger_targets = merger_targets(~isnan(merger_targets));
num_mergers = numel(merger_targets);

% Initialize and put in struct
[merges(1:num_mergers).origin] = deal([]);
[merges(1:num_mergers).target] = deal([]);
for i = 1:num_mergers
    merges(i).origin = find(correspondence == merger_targets(i));
    merges(i).target = merger_targets(i);
end

end