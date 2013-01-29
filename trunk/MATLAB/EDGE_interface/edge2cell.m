function cell_structs = edge2cell(measurements,frames,sliceID)
%EDGE2CELL Converts an array of EDGE measurements to cell-centric
%structures.
%
% SYNOPSIS: cell_structs = edge2cell(measurements,frames,sliceID)
%
% INPUT: measurements - array of EDGE measurements
%        frames - (optional) only load these frames. Either an array of
%                 indices or the string 'all'. Default is 'all'.
%        sliceID - (optional) only load these Z slices. Either an array of
%                 indices or the string 'all'. Default is 'all'.
% OUTPUT: cell_structs - 1-by-num_cell structure array where fields are the
%                measurement names
%
% xies@mit.edu

N = size(measurements(1).data,3);
if ~exist('frames','var'), frames = 'all'; end
if ~exist('sliceID','var'), sliceID = 'all'; end

measurement_names = make_valid_fieldname({measurements.name});
m1 = get_substack_msmt(measurements,frames,sliceID,N);
m1 = {m1.data};
cell_structs(N) = cell2struct(m1,measurement_names,2);

for i = 1:N-1
    m1 = get_substack_msmt(measurements,'all',sliceID,i);
    m1 = {m1.data};
    cell_structs(i) = cell2struct(m1,measurement_names,2);
end

end