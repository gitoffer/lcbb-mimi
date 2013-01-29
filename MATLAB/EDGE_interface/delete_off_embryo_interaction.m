function D_fixed = delete_off_embryo_interaction(D,IDs)
% Given an "interaction matrix" generated across all cells in multiple
% embryos, will delete cells-cell interaction terms that are across
% different embryos, as this is often unphysical
%
% SYNOPSIS: D_fixed = delete_off_embryo_interactions(D,IDs);
%
% xies@mit.edu

D_fixed = D;
for i = 1:numel(unique([IDs.which]))
    D_fixed([IDs.which]==i,[IDs.which]~=i) = NaN;
end

end