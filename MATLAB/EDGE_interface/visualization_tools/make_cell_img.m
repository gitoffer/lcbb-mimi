function varargout = make_cell_img(h)
%MAKE_CELL_IMG Crops out a cell segmented by EDGE from the raw image
%stacks.
%
% USAGE: F = make_cell_img(handle)
%
% INPUT: handle fields:
%        vx, vy - cell arrays of vertex coordinates exported by EDGE
%        frames2load - a vector of frames to include in the movie (image_frames)
%        cellID - EDGE ID
%        channels - the names of the image channels you want to use... as
%                   defined by EDGE. e.g. {'Myosin','Membranes'}
%        border - 'on'/'off' (turn on the segmented cell border, default 'off')
%        input - input file structure
% 
%        (opt)
%        mask -
%        axes - alternative parent object
%
% OUTPUT: F (opt) - MATLAB's movie structure. To play, use movie(F).
% 
% SEE ALSO: MAKE_PULSE_MOVIE
%
% xies@mit.edu 2012.

% ---- Parse input handle -----

input = h.input;
frames = h.frames2load;
channels = h.channels;
sliceID = h.input.actual_z;
cellID = h.cellID;

path = fileparts(input.folder2load);
if input.fixed % fixe dimage
    vx = h.vx(cellID);
    vy = h.vy(cellID);
else % live image
    vx = h.vx(:,cellID);
    vy = h.vy(:,cellID);
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
    end

end
% Turn on border by default
if ~isfield(h,'border'), h.border = 'off'; end
% Parse axes
if ~isfield(h, 'axes'), h.axes = gca; end

% ---- Construct image -----

if input.fixed
    movie_frames = input.t0;
else
    % Correct for EDGE lag
    movie_frames = frames + input.t0;
end
% find bounding box
box = find_bounding_box(vx,vy);

% If all NaN
if cellfun(@(x) any(isnan(x)),vx)
    warning(['No non-NaN values for cell # ' int2str(cellID) '.']);
    if nargout > 0, varargout{1} = []; end
    return
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
    
    imshow(cast(F,'uint8'),'Border','loose','Parent',h.axes);
    title(h.axes,['Time: ' int2str((movie_frames(i)-input.tref)*input.dt) ' (sec)']);
    
    if nargout > 0, G(i) = getframe(gca); end
    
end

if nargout > 0, varargout{1} = G; end

end

function box = find_bounding_box(vx,vy)
% Find a square bounding box with border size 15 around all vertices of the
% cell.

left = floor(nanmin(cellfun(@nanmin,vx)));
right = nanmax(cellfun(@nanmax,vx));
bottom = floor(nanmin(cellfun(@nanmin,vy)));
top = nanmax(cellfun(@nanmax,vy));

width = ceil(right - left + 1);
height = ceil(top - bottom + 1);

side_length = max(width,height) + 15;

box = [left-10 bottom-10 side_length side_length];

end