function pulse = load_mdf_pulse(mdf_matrix,embryo_struct,input,num_cells,varargin)
%LOAD_MDF_PULSE Loads tracked pulses from an MDF matrks, as read in by
% READ_MDF.
%
% USAGE: pulse = load_mdf_pulse(tracks,embryo_struct,input,num_cells)
%        pulse = load_mdf_pulse(tracks,embryo_struct,input,num_cells,master_time)
%
% INPUT: tracks - MDF matrix
%        embryo_struct - output of EDGE2EMBRYO
%        input - input structure
%        master_time (OPT) - if the desire frame numbers are not the
%              original raw image frames, but the aligned frame numbers
%
% OUTPUT: pulse.frames - the frames that were active
%         pulse.cellID - the cellID (embryo-specific)
%
% SEE ALSO: EDGE2EMBRYO, INPOLYGON
% 
% xies@mit.edu

% Get rid of other zslices and squeeze the singleton dimension
vx = squeeze(embryo_struct.vertex_x(:,input.zslice,:));
vy = squeeze(embryo_struct.vertex_y(:,input.zslice,:));
cx = squeeze(cell2mat(embryo_struct.centroid_x(:,input.zslice,:))) ...
    /input.um_per_px;
cy = squeeze(cell2mat(embryo_struct.centroid_y(:,input.zslice,:))) ...
    /input.um_per_px;

% Get the number of tracks in matrix
num_tracks = max(unique(mdf_matrix(:,1)));
num_cell_pad = cumsum([0 num_cells]);

% Get mater_time from varargin if defined
if nargin > 4, master_time = varargin{1}; end

% Initialize
[pulse(1:num_tracks).frame] = deal(NaN);
[pulse(1:num_tracks).cellID] = deal(NaN);
[pulse(1:num_tracks).cell] = deal(NaN);
[pulse(1:num_tracks).embryoID] = deal(input.embryoID);

for i = 1:num_tracks
    
    % Extract one track at a time
    this_track = mdf_matrix(mdf_matrix(:,1) == i,:);
    
    if isempty(this_track), continue; end
    
    % Get the frames in which this track is active
    frames = this_track(:,end);
    
    % Make sure there are more than 2 frames in the track
    if numel(frames) < 3, continue; end
    
    % Make sure that the frame doesn't lie beyond the well-tracked region
    if mean(frames) > input.last_segmented, continue; end
    
    % Get the coordinates of the track and the average "center"
    x = this_track(:,3);
    center_x = mean(x);
    y = this_track(:,4);
    center_y = mean(y);
    
    % Sort distance between average track coordinate to all cell centroids
    dists = sqrt(...
        (center_x - cx(frames(1),:)).^2 + (center_y - cy(frames(1),:)).^2);    
    [~,order] = sort(dists);
    
    found = 0; index = 0;
    % Try until an overlapping cell is found
    while ~found && index < num_cells(input.embryoID)
        % Check out track center is within cell
        index = index + 1;
        found = inpolygon(center_x,center_y, ...
            vx{frames(1),order(index)},vy{frames(1),order(index)});
    end
    if ~found, continue; end
    
    if nargin < 5
        % Use the frame-number of the raw image
        pulse(i).frame = frames;
    else
        % Use the frame-number of the aligned embryos
        first_match = find(master_time.frame == frames(1),1);
        pulse(i).frame = first_match : first_match + numel(frames);
    end
    if isempty(order), keyboard; end
    pulse(i).cellID = order(index);
    pulse(i).cell = num_cell_pad(input.embryoID) + order(index);
    pulse(i).mdfID = i;

end

end