function [origin,target] = find_merges(map)
%FIND_MERGES Given a MAP (container.Map object), a hashmap from a set of
% keys (set A) to a corresponding set of values (set B), return the members
% in set A which map onto the same object in set B.
%
% USAGE: merges = find_merges(map)
%
% INPUT: map - container.Map (hashmap object)
% 
% OUTPUT: origin - cell array of the objects in set A that map onto the
%                  same object in set B
%         target - cell array of the object in set B that the merged
%                  objects in origin correspond to
%
% xies@mit.edu Feb 2013

% Get all the keys (objects in A) and values (object in B)
keylist = map.keys; vlist = map.values;

% Find duplicated values in B (via SORT + DIFF)
[sorted_values,I] = sort( cell2mat(vlist) );
duplicates = find(diff(sorted_values) == 0);
duplicates = unique([duplicates duplicates + 1]);

% Find all the unique duplicated targets
target = num2cell(unique( [vlist{ I(duplicates) }] ));

% Collect the origin/targets
origin = cell(1,numel(target));
for i = 1:numel(target)
    origin{i} = [keylist{ cellfun(@(x) x == target{i} , vlist )}];
end

% Depricated due to MAP object

% % Get rid of the non-mapped ones (0)
% correspondence(correspondence == 0) = NaN;
% 
% % sort and take the derivative to find the same values
% [sorted_corr,I] = sort(correspondence);
% % I = reverse_index(I);
% duplicates = find(diff(sorted_corr) == 0);
% duplicates = unique([duplicates duplicates+1]); % boundary correction
% 
% % Get a merged-target list
% merger_targets = unique(correspondence(I(duplicates)));
% merger_targets = merger_targets(~isnan(merger_targets));
% num_mergers = numel(merger_targets);
% 
% % Initialize and put in struct
% [merges(1:num_mergers).origin] = deal([]);
% [merges(1:num_mergers).target] = deal([]);
% for i = 1:num_mergers
%     merges(i).origin = find(correspondence == merger_targets(i));
%     merges(i).target = merger_targets(i);
% end

end