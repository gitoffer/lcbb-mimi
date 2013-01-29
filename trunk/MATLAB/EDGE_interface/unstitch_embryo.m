function m = unstitch_embryo(mstitch,IDs,master_time,embryoID)

% Unpad and un-align measurements from a single embryo from the aligned
% array.

time = master_time(embryoID).frame;
cellIDs = [IDs.which];

m = mstitch(find(~isnan(time)),find(cellIDs == embryoID)); %#ok<FNDSB>

end