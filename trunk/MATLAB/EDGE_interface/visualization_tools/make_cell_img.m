function G = make_cell_img(h)
%MAKE_CELL_IMG Crops out a cell segmented by EDGE from the raw image
%stacks.
%
% USAGE: F = make_cell_img(handle)
%
% INPUT: handle fields:
%        vx, vy - cell arrays of vertex coordinates exported by EDGE
%        frames - a vector of frames to include in the movie (padded)
%        sliceID - the ORIGINAL slice number in the movie imported by EDGE
%        cellID - the cell you want to make a movie of
%        channels - the names of the image channels you want to use... as
%                   defined by EDGE. e.g. {'Myosin','Membranes'}
%
% OUTPUT: F - MATLAB's movie structure. To play, use movie(F).
%
% SEE ALSO: MAKE_PULSE_MOVIE
%
% xies@mit.edu 2012.


input = h.input;
frames = h.frames2load;
channels = h.channels;
sliceID = h.input.actual_z;
cellID = h.cellID;

path = fileparts(input.folder2load);
vx = h.vx(:,cellID);
vy = h.vy(:,cellID);

% Correct for lag
movie_frames = frames(~isnan(frames));
frames = find(~isnan(frames));

% num_frames = size(vx);

box = find_bounding_box(vx,vy);

% If all NaN
if cellfun(@(x) any(isnan(x)),vx)
    warning(['No non-NaN values for cell # ' int2str(cellID) '.']);
    G = [];
    return
end

% Check for number of channels. If > 3, then cannot use RGB.
if numel(channels) > 3, error('Cannot display more than 3 channels');
elseif numel(channels) == 3 && ~isempty(varargin)
    error('Cannot display the 3 specified channels as well as an additional measurement.');
end

% Colored measurements? AKA the .measurement field is a RGB matrix
if isfield(h,'measurement')
	measurement = h.measurement;
    measurement = measurement./nanmax(measurement(:)).*240;
    if size(measurement,2) == 3
        colorized = 1;
    else
        colorized = 0;
%         if numel(measurement) ~= numel(movie_frames)
%             error('Measurement array size must be the same as the number of desired frames');
%         end
    end

end

% Load all the FRAMES
for i = 1:numel(movie_frames)
    F = zeros(box(4)+1,box(3)+1,3);
    
    % Load specified channels
    for j = 1:numel(channels)
        
        p = pwd;
        
        this_folder = [path '/' channels{j}];
        cd( this_folder );
        if strcmpi(channels{j},'Membranes'),
            this_folder = [this_folder '/Raw']; % Only use the raw membranes
        end
        
        filename = image_filename(movie_frames(i),sliceID,this_folder);
        im = imread(filename);
        
        ker = fspecial('gaussian',10,1);
        im = imfilter(im,ker,'symmetric');
        im = rescale(double(im),0,2^8-1);
        
        F(:,:,j) = imcrop(im,box);
        
        cd(p);
        
    end
    % Make sure that there is at least one frame at which there is an EDGE
    % tracking of the specified cell
    if all(~isnan(vx{frames(i)}))
        mask = poly2mask(vx{frames(i)}-box(1),...
            vy{frames(i)}-box(2),...
            box(4)+1,box(3)+1);
        
        % If we're going to plot the 'measurement' coloration also
        if isfield(h,'measurement')
            % make colored polygon if measurement is 3-channels
            if colorized
                mask = mask(:,:,ones(1,3));
                foo = measurement(frames(i),:);
                foo = shiftdim(foo,-1);
                mask = mask.*foo(ones(size(mask,1),1),ones(size(mask,2),1),:);
                F = F + mask;
            else
                mask = mask*measurement(frames(i));
                F(:,:,3) = mask;
            end
        end
        
        % Make border white
        if strcmpi(h.border,'on')
            border = bwperim(mask(:,:,1));
            F(:,:,1) = F(:,:,1) + border.*2^8-1;
            F(:,:,2) = F(:,:,2) + border.*2^8-1;
            F(:,:,3) = F(:,:,3) + border.*2^8-1;
        end
    end
    
    imshow(cast(F,'uint8'),'Border','loose');
    title(['Time: ' int2str((movie_frames(i)-input.tref)*input.dt) ' (sec)']);
    
    G(i) = getframe(gca);
    
end

end

% Find a square bounding box with border size 15 around all vertices of the
% cell.
function box = find_bounding_box(vx,vy)

left = floor(nanmin(cellfun(@nanmin,vx)));
right = nanmax(cellfun(@nanmax,vx));
bottom = floor(nanmin(cellfun(@nanmin,vy)));
top = nanmax(cellfun(@nanmax,vy));

width = ceil(right - left + 1);
height = ceil(top - bottom + 1);

side_length = max(width,height) + 15;

box = [left-10 bottom-10 side_length side_length];

end