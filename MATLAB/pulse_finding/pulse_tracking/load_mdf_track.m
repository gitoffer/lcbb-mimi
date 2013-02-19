function tracks = load_mdf_track(mdf_matrix,embryo_struct,threshold)
%LOAD_MDF_TRACKS Loads tracked pulses from a MDF matrix into a TRACK
% object
%
% USAGE: tracks = load_mdf_track(mdf_matrix,embryo_struct)
%
% See also TRACK, INPOLYGON
% xies@mit.edu

% Load time, cell number, and input from embryo_struct
developmental_timeframe = embryo_struct.developmental_timeframe;
num_cells = [embryo_struct.num_cell];
input = embryo_struct.input;

% Get rid of other zslices and squeeze out singleton
vx = squeeze(embryo_struct.vertex_x(:,input.zslice,:));
vy = squeeze(embryo_struct.vertex_y(:,input.zslice,:));
cx = squeeze(cell2mat(embryo_struct.centroid_x(:,input.zslice,:))) ...
	/input.um_per_px;
cy = squeeze(cell2mat(embryo_struct.centroid_y(:,input.zslice,:))) ...
	/input.um_per_px;

% Get the number of tracks in the matrix
num_tracks = max(unique(mdf_matrix(:,1)));
% Construct padded num_cell count for setting correct stackID
num_cell_pad = cumsum([0 num_cells]);

trackID = 0;
for i = 1:num_tracks

	% Extract one track from matrix
	this_track = mdf_matrix(mdf_matrix(:,1) == i,:);
	
	% If nothing found, move onto next number
	if isempty(this_track), continue; end

	% Get the active frames
	frames = this_track(:,end);

	% Make sure there are more than a threshold number of active frames
	if numel(frames) < threshold; end
	
	% Make sure that the frame doesn't lie beyond the well-tracked region
	if mean(frames) > input.last_segmented, continue; end
	
	% Get the coordinates of the track and the centroid of track
	x = this_track(:,3);
	track_cx = mean(x);
	y = this_track(:,4);
	track_cy = mean(y);

	% Sort the distance between track cenroid to all cell centroids
	dists = sqrt( ...
		(track_cx - cx(frames(1),:)).^2 + (track_cy - cy(frames(1),:)).^2);
	[~,order] = sort(dists);

	found = 0; index = 0;
	% Try until an overlapping cell is found using INPOLYGON
	while ~found && index < num_cells(input.embryoID)
		% Check if track center is within cell
		index = index + 1;
		found = inpolygon( track_cx,track_cy,...
			vx{frames(1),order(index)} , vy{frames(1),order(index)} );
	end
	if ~found, continue; end % Not in EDGEd cells

	% Assign trackID
	trackID = trackID + 1;

	% Collect relevant information into structures used to construct TRACK
	IDs.embryoID = input.embryoID; IDs.mdfID = i;
	IDs.cellID = order(index); IDs.stackID = num_cell_pad(input.embryoID) + order(index);

	% Collect the time/frame of track WRT aligned developmental time
	first_match = find(developmental_timeframe.frame == frames(1), 1);
	track_dev_tf.frame = first_match : first_match + numel(frames);
	track_dev_tf.time = developmental_timeframe.time(track_dev_tf.frame);

	% Construct Track object
	tracks(input.embryoID,trackID) = Track(trackID,IDs,track_dev_tf,frames');

end
