function G = make_cell_img(vx,vy,frames,sliceID,cellID,input,channels,varargin)
%MAKE_CELL_IMG Crops out a cell segmented by EDGE from the raw image
%stacks.
%
% USAGE: F = make_cell_img(vx,vy,frames,sliceID,cellID,input,channels)
%
% INPUT: vx, vy - cell arrays of vertex coordinates exported by EDGE
%        frames - a vector of frames to include in the movie
%        sliceID - the ORIGINAL slice number in the movie imported by EDGE
%        cellID - the cell you want to make a movie of
%        channels - the names of the image channels you want to use... as
%                   defined by EDGE. e.g. {'Myosin','Membranes'}
%
% OUTPUT: F - MATLAB's movie structure. To play, use movie(F).
%
% xies@mit.edu 2012.

path = fileparts(input.folder2load);

vx = vx(frames,cellID);
vy = vy(frames,cellID);
% num_frames = size(vx);

box = find_bounding_box(vx,vy);

% F = zeros(box(4)+1,box(3)+1,numel(frames),numel(channels));
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

if ~isempty(varargin)
    measurement = varargin{1};
    measurement = measurement./nanmax(measurement(:)).*150;
    if size(measurement,2) == 3
        colorized = 1;
    else
        colorized = 0;
        if numel(measurement) ~= numel(frames)
            error('Measurement array size must be the same as the number of desired frames');
        end
    end

end

for i = 1:numel(frames)
    F = zeros(box(4)*2+2,box(3)*2+2,3);
    for j = 1:numel(channels)
        
        this_folder = [path '/' channels{j}];
        cd( this_folder );
        if strcmpi(channels{j},'Membranes'),
            this_folder = [this_folder '/Raw']; % Only use the raw membranes
        end
        
        filename = image_filename(frames(i),sliceID,this_folder);
        im = imread(filename);
        
        ker = fspecial('gaussian',10,1);
        im = imfilter(im,ker,'symmetric');
        im = rescale(double(im),0,2^8-1);
        
        F(:,:,j) = imresize(imcrop(im,box),2);
        
    end
    if ~isempty(varargin)
        if ~isnan(vx{i})
            mask = poly2mask(vx{i}-box(1),vy{i}-box(2),box(4)+1,box(3)+1);
            if colorized
                mask = mask(:,:,ones(1,3));
                foo = measurement(i,:);
                foo = shiftdim(foo,-1);
                mask = mask.*foo(ones(size(mask,1),1),ones(size(mask,2),1),:);
                F = F + imresize(mask,2);
            else
                mask = mask*measurement(i);
                F(:,:,3) = imresize(mask,2);
            end
        end
    end
    
    imshow(cast(F,'uint8'));
    title(['Frame ' int2str(frames(i)) ]);
    
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