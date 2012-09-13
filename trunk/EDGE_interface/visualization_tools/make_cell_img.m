function G = make_cell_img(vx,vy,frames,sliceID,cellID,input,channels)

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

for i = 1:numel(frames)
    F = zeros(box(4)+1,box(3)+1,3);
    for j = 1:numel(channels)
        
        this_folder = [path '/' channels{j}];
        cd( this_folder );
        if strcmpi(channels{j},'Membranes'),
            this_folder = [this_folder '/Raw']; % Only use the raw membranes
        end
        
        filename = image_filename(frames(i),sliceID,this_folder);
        im = imread(filename);
        
        F(:,:,j) = imcrop(im,box);
        
    end
    
    imshow(cast(F,'uint8'));
    title(['Frame ' int2str(frames(i)) ]);
        
    G(i) = getframe(gcf);
end

end


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