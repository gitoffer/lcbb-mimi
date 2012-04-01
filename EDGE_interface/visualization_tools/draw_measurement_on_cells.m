function movie = draw_measurement_on_cells(EDGEstack,measurement,X,Y,um_per_px)
%DRAW_MEASUREMENT_ON_CELLS Generate a movie of segmented cells with the
%cells colored by some input measurement
%
% USE: movie = draw_measurement_on_cells(EDGEstack,measurement,X,Y,um_per_px);
%


% Preallocate
[num_frames,num_cells] = size(measurement);
movie = nan(Y,X,num_frames);

for i = 1:num_frames
    this_frame = nan(Y,X);
    for j = 1:num_cells
        mask = make_cell_mask(EDGEstack,i,1,j,X,Y,um_per_px);
        this_frame(mask) = measurement(i,j);
    end
    movie(:,:,i) = this_frame;
end

movie = movie(end:-1:1,:,:);
end