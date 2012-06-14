function [cc,ccID] = connected_cells(roi,neighborID)
%CONNECTED_CLUSTERS Find the number of cells connected to each cell, given
%a ROI.
%
% SYNOPSIS: [cc,ccID] = connected_clusters(roi,neighborID)
%
% xies@mit.edu. May 2012.

[num_frames,num_cells] = size(roi);
cc = nan(num_frames,num_cells);
ccID = cell(num_frames,num_cells);

for i = 1:num_cells
    for t = 1:num_frames
        neighbors = neighborID{1,i};
        if any(~isnan(neighbors))
            neighbors = roi(t,neighbors);
            cc(t,i) = numel(neighbors(neighbors > 0));
            ccID{t,i} = neighbors(neighbors >0);
        else
            ccID{t,i} = NaN;
        end
    end
end

end
