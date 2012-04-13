function msmts = get_substack_msmt(measurements,frames,sliceID,cellID)
% Extract the measurements for a subset of cells (and optionally for a
% given slice).
% NOTE: Not too useful... need to get rid of function.
%
% SYNOPSIS: msmts = get_msmt_for_cell(measurements,cellID,sliceID)
%
% xies@mit.edu 10/2011.

msmts = measurements;
[T,Z,N] = size(measurements(1).data);
if strcmpi(frames,'all'), frames = 1:T; end
if strcmpi(sliceID,'all'), sliceID = 1:Z; end
if strcmpi(cellID,'all'), cellID = 1:N; end

for i = 1:numel(measurements)
    m = measurements(i);
    data = measurements(i).data(frames,sliceID,cellID);
    data = squeeze(data);
    
    m.data = data;
    msmts(i) = m;
end

end