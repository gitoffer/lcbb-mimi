function tracks = load_mdf_track(mdf_matrix,embryo_stack,embryoID,min_frame,cells)
%LOAD_MDF_TRACKS Loads tracked pulses from a MDF matrix into a TRACK
% object
%
% USAGE: tracks = load_mdf_track(mdf_matrix,embryo_stack,thresh4match,cells)
%
% See also TRACK, INPOLYGON
% xies@mit.edu

num_cells = [embryo_stack.num_cell];
% Extract single embryo structure
embryo_struct = embryo_stack(embryoID);

% Load time, cell number, and input from embryo_struct
dev_time = embryo_struct.dev_time;
dev_frame = embryo_struct.dev_frame;
input = embryo_struct.input;

% Get rid of other zslices and squeeze out singleton
vx = squeeze( embryo_struct.vertex_x );
vy = squeeze( embryo_struct.vertex_y );
cx = squeeze( embryo_struct.centroid_x ) / input.um_per_px;
cy = squeeze( embryo_struct.centroid_y ) / input.um_per_px;

% Get the number of tracks in the matrix
num_tracks = max(unique(mdf_matrix(:,1)));
% Construct padded num_cell count for setting correct stackID
num_cell_pad = cumsum([0 num_cells]);

trackID = 0;
for i = 1:num_tracks

	% Extract one track from matrix
	this_mdf = mdf_matrix(mdf_matrix(:,1) == i,:);
	
	% If nothing found, move onto next number
	if isempty(this_mdf), continue; end

	% Get the active frames
	frames = this_mdf(:,end);

	% Make sure there are more than a threshold number of active frames
	if numel(frames) < min_frame; end
	
	% Make sure that the frame doesn't lie beyond the well-tracked region
	if mean(frames) > input.last_segmented, continue; end
	
    % Collect the image frames
    img_frame = frames;
    
	% Get the coordinates of the track and the centroid of track
	x = this_mdf(:,3);
	track_cx = mean(x);
	y = this_mdf(:,4);
	track_cy = mean(y);
    
    % Convert image-frames into dev-frames
    f0 = find( 1 == dev_frame );
    frames = frames + f0 - 1;

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
    this_track.trackID = trackID;
    
	% Collect relevant information into track struct
    this_track.embryoID = input.embryoID; this_track.mdfID = i;
    this_track.cellID = order(index);
    this_track.stackID = num_cell_pad(input.embryoID) + order(index);

	% Collect the time/frame of track WRT aligned developmental time
	this_track.dev_frame = frames;
	this_track.dev_time = dev_time(frames);
    % Collect the frames WRT image time
    this_track.img_frame = img_frame;
    
	% Construct Track object
	tracks(trackID) = this_track;

end

% filter out non-fitted cells

tracked_cells = [unique([tracks.stackID])];
unfit_cells = tracked_cells( ~[cells(tracked_cells).flag_fitted] );
[tracks(ismember([tracks.stackID],unfit_cells))] = [];

for i = 1:numel(tracks)
    tracks(i).trackID = i;
end

end
