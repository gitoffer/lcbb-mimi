function [matches,track,pulse] = categorize_mapping(nbm, pulse, track)

if strcmpi(nbm.nameA,'pulse')
    mapPT = 'dictAB';
    mapTP = 'dictBA';
else
    mapPT = 'dictBA';
    mapTP = 'dictAB';
end

% -- Quantify merges --
[trackID,pulseID] = find_merges(nbm.(mapPT));
[ matches.merge( 1:numel(trackID) ).trackID ] = deal(trackID{:});
[ matches.merge( 1:numel(trackID) ).pulseID ] = deal(pulseID{:});
% Annotate pulse/track with merges
for i = 1:numel(trackID)
    [ pulse(pulseID{i}).category ] = deal('merge');
    [ track(trackID{i}).category ] = deal('merge');
end

% -- Quantify splits --
[pulseID,trackID] = find_merges(nbm.(mapTP));
[ matches.split( 1:numel(trackID) ).pulseID ] = deal(pulseID{:});
[ matches.split( 1:numel(trackID) ).trackID ] = deal(trackID{:});
% Annotate pulse/track with splits
for i = 1:numel(trackID)
    [ pulse(pulseID{i}).category ] = deal('split');
    [ track(trackID{i}).category ] = deal('split');
end

% -- Quantify missed/added --
matchedPT_trackID = nbm.(mapPT).values;
matchedTP_pulseID = nbm.(mapTP).values;

matches.miss.trackID = [track(~ismember([track.trackID],cell2mat(matchedPT_trackID))).trackID];
% Annotate track with misses
[ track(matches.miss.trackID).category ] = deal('miss');

matches.add.pulseID = [pulse(~ismember([pulse.pulseID],cell2mat(matchedTP_pulseID))).pulseID];
% Annotate track with adds
[ pulse(matches.add.pulseID).category ] = deal('add');

% -- Quantify one-to-one matches --
% Find all tracks within the pulse-fitted cells, and not belonging to
% merge/split/miss
one2one_origins = [track( ...
    ~ismember([track.trackID], unique([matches.merge.trackID matches.split.trackID])) ...
    & ~ismember([track.trackID], matches.miss.trackID) ...
    & ismember([track.trackID], cell2mat(nbm.(mapTP).keys)) ).trackID];
% initialize
[one2one(1:numel(one2one_origins)).trackID] = deal([]);
[one2one(1:numel(one2one_origins)).pulseID] = deal([]);
% Assign
for i = 1:numel(one2one_origins)
    one2one(i).trackID = one2one_origins(i);
    one2one(i).pulseID = nbm.(mapTP)( one2one_origins(i) );
end
% Annotate one2one matches ontp pulse/track structures
[ track([one2one.trackID] ).category] = deal('one2one');
[ pulse([one2one.pulseID] ).category] = deal('one2one');

% Collect into structure
matches.one2one = one2one;
matches.num_tracks = numel(track);
matches.num_pulses = numel(pulse);

end