function one2one = find_one2one(nbm)

key_trackID = nbm.dictTrackFit.keys;
% val_trackID = nbm.dictFitTrack.values;
% val_fitID = nbm.dictTrackFit.values;
% key_fitID = nbm.dictFitTrack.keys;

count = 1;
for i = 1:numel(key_trackID)
    
    match_fitID = nbm.dictTrackFit(key_trackID{i});
    if nbm.dictFitTrack(match_fitID) == key_trackID{i}
        one2one(count).trackID = key_trackID{i};
        one2one(count).fitID = match_fitID;
        count = count + 1;
    end
    
end
