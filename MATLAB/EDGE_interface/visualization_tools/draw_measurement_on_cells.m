function movie = draw_measurement_on_cells(cells,measurement,input)
%DRAW_MEASUREMENT_ON_CELLS Generate a movie of segmented cells with the
% cells colored by some input measurement (e.g. area). Will return a pixel
% image, instead of a scalable "vector" image with the PATCH object. For
% a vector image, see DRAW_MEASUREMENT_ON_CELLS_PATCH
%
% USE: movie = draw_measurement_on_cells(cells,measurement,input);
%

% Preallocate
[num_frames,num_cells] = size(measurement);
X = input.X; Y = input.Y;
movie = nan(Y,X,num_frames);

for i = 1:num_frames
    this_frame = nan(Y,X);
    for j = 1:num_cells
        mask = bwperim(make_cell_mask(cells(j),i,input));
        this_frame(mask) = measurement(i,j);
    end
    movie(:,:,i) = this_frame;
end

movie = movie(end:-1:1,:,:);

end