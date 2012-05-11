function [cluster_size,clusters,cluster_number] = connected_clusters(roi,neighborID)
%CONNECTED_CLUSTERS Find the set of all connected cell clusters given a
%mask.
%
% SYNOPSIS: [cluster_size,cluster_cellID,cluster_number] =
%                  connected_clusters(roi,neighborID);
%
% INPUT: ROI - mask
%        neighborID - identity of neighbors
% OUTPUT: cluster_size - number of cells in clusters
%         cluster_cellID - cellIDs in each cells
%         cluster_number - number of disparate clusters
%
% xies@mit.edu May 2012.

[num_frames,num_cells] = size(roi);

clusters = cell(1,num_frames);
cluster_size = cell(1,num_frames);
cluster_number = zeros(1,num_frames);
for t = 1:num_frames
    
    already_seen = zeros(1,num_cells); % keep track of what was already included in the clusters
    num_clusters = 0; % keep track of number of clusters
    this_cluster = {};
    this_size = []; % keep track of number of cells in each cluster
    for i = 1:num_cells
        my_neighbors = neighborID{1,i}'; % neighbors of initial cell i
        
        if roi(t,i) > 0 && ~any(isnan(my_neighbors)) && ~already_seen(i)
            % initial cell is on, has non NaN neighbors, and hasn't been
            % included yet
            
            % include cell i
            trial_cluster = i;
            % find neighbors of cell i, that is on
            on_neighbors = my_neighbors.*(roi(t,my_neighbors)).*(~already_seen(my_neighbors));
            on_neighbors = on_neighbors(on_neighbors > 0);
            
            % use the neighbors of cell i to 'percolate' throughout the
            % cluster
            while numel(setxor(trial_cluster,[i on_neighbors]))
                % add non-unique neighbors to cluster
                trial_cluster = unique([trial_cluster on_neighbors]);
                
                % find neighbors of neighbors
                other_neighbors = cat(1,neighborID{1,on_neighbors});
                % neighbors of neighbors are non-NaN
                if numel(other_neighbors(~isnan(other_neighbors)))
                    % find all unique, non NaN, on, not already seen
                    % neighbors
                    other_neighbors = other_neighbors(~isnan(other_neighbors))';
                    other_neighbors = other_neighbors.*roi(t,other_neighbors).*(~already_seen(other_neighbors));
                    other_neighbors = other_neighbors(other_neighbors > 0);
                    
                    on_neighbors = unique([on_neighbors, other_neighbors]);
                end
                % make the included cells already seen
                already_seen(trial_cluster) = 1;
                
            end
            
            num_clusters = num_clusters + 1;
            already_seen(trial_cluster) = 1;
            this_cluster{num_clusters} = trial_cluster;
            this_size(num_clusters) = numel(trial_cluster);
        end
    end
    clusters{t} = this_cluster;
    cluster_size{t} = this_size;
    cluster_number(t) = num_clusters;
    
end

end