function F = make_embryo_pulse_movie(fits,cells,input,path,flag2label)
%MAKE_EMBRYO_PULSE_MOVIE - Make a movie of all pulses found within
% an embryo. Only the center frames of each pulse is highlighted,
% and the fitID and cellID of that pulse will be shown in text.
%
% SYNOPSIS:

if nargin < 4
    path = '~/Desktop/movie.avi';
    flag2label = 0;
elseif nargin < 5
    flag2label = 0;
end

% check that all fits and cells belong to the same embryo
if numel(unique([fits.embryoID cells.embryoID])) > 1
	error('All CellObj and Fitted must belong to the same embryo.');
end

% get non-NaN times
dev_time = cells(1).dev_time;
dev_time = dev_time( ~isnan(dev_time) );

% get the central frame of a pulse
center_frames = cellfun(@(x) fix(mean(x)),{fits.width_frames});
% get fitIDs + cellIDs for drawing later
fIDs = [fits.fitID];
cIDs = [fits.cellID];

num_frames = numel(dev_time);
X = input.X; Y = input.Y;

F = avifile(path,'compression','None');
fig = figure(1);
for frame = 1:num_frames
    
	this_img = zeros(Y,X);
	% Find all highlighted cells and create a mask
	idx = find(center_frames == frame);
	num_on = numel(idx);
	on_cells = cIDs(idx);
	on_fits = fIDs(idx);

	x = zeros(1,num_on);
	y = zeros(1,num_on);
	str_cellID = cell(1,num_on);
	str_fitID = cell(1,num_on);
    for i = 1:num_on

		% create mask
        mask = cells(on_cells(i)).make_mask(frame,input);
        this_img = this_img + double(mask);

		% grab centroids for plotting
		cx = cells(on_cells(i)).centroid_x; cy = cells(on_cells(i)).centroid_y;
		cx = cx(frame,:)/input.um_per_px; cy = cy(frame,:)/input.um_per_px;
		x(i) = cx; y(i) = cy;
		% grab fitID + cellID
		str_cellID{i} = on_cells(i);
		str_fitID{i} = on_fits(i);
    end

    imshow(this_img,[]);
    if flag2label
        hold on;
        text(x-10,y+8,str_fitID,'Color','red','fontsize',10);
        text(x-10,y-8,str_cellID,'Color','green','fontsize',10);
        hold off;
    end
    
    F = addframe(F,fig);
    
end

F = close(F);

end
