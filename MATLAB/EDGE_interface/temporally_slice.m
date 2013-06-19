function [sliceID,tbins,Ninslice] = temporally_slice(embryo_stack,dt)
%TEMPORALLY_SLICE Temporally slice
%
% USAGE:
% [sliceID,tbins,Ninslice] = temporally_slice(embryo_stack,dt)
%
% INPUT: embryo_stack
%        dt - A 1xNembryo vector of time bins for temporal slicing (sec)
%
% OUTPUT: sliceID - for all measurements from all cells in embryo_stack,
%                   gives the temporal slice number
%         tslices - left edge of temporal slice
%         Ninslice - number of things in each slice
%
% SEE ALSO: KDE_GAUSS, CTA_KDE_AREA
%
% xies@mit.edu

data = cat(2,embryo_stack.area);

% -- Generate temporal slicing --
min_time = nanmin([embryo_stack.dev_time]);
max_time = nanmax([embryo_stack.dev_time]);
tbin_edges = [-Inf min_time + dt: dt :max_time - dt Inf];
[~,which_slice] = histc(cat(1,embryo_stack.dev_time),tbin_edges);
sliceID = zeros(size(data));
% Expand binID from embryo to each cell
padding = [0 cumsum([embryo_stack.num_cell])];
for i = 1:numel( embryo_stack )
    sliceID(: , padding(i) + 1 : embryo_stack(i).num_cell + padding(i)) = ...
        which_slice( ones(1,embryo_stack(i).num_cell)*i , :)';
end

tbins = [min_time tbin_edges( 2 : end - 1 )];

% Count number in slice
Ninslice = hist(sliceID( ~isnan(data) & sliceID > 0), numel(unique(sliceID)) - 1);

end