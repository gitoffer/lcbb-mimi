function movie = draw_measurement_on_cells(m,measurement,X,Y,um_per_px)
%DRAW_MEASUREMENT_ON_CELLS Generate a movie of segmented cells with the
%cells colored by some input measurement

% Generate the correct time indexing vector

% % Grab the grid vectors

% Preallocate
num_cells = size(m(1).data,3);
num_frames = size(m(1).data,1);

movie = nan(Y,X,num_frames);
for i = 1:num_frames
    this_frame = nan(Y,X);
    for j = 1:num_cells
        mask = make_cell_mask(m,i,1,j,X,Y,um_per_px);
        this_frame(mask) = measurement(i,j);
    end
    movie(:,:,i) = this_frame;
end

movie = movie(end:-1:1,:,:);
end