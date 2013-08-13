function F = make_embryo_pulse_movie(fits,cells,input,embryoID)

if nargin > 3
    fits = fits.get_embryoID(embryoID);
    cells = cells.get_embryoID(embryoID);
end

dev_time = cells(1).dev_time;
dev_time = dev_time( ~isnan(dev_time) );
stackIDs = cat(1,fits.stackID);
center_frames = cellfun(@(x) fix(mean(x)),{fits.width_frames});

num_cells = numel(cells);
num_frames = numel(dev_time);

X = input.X; Y = input.Y;

for frame = 1:num_frames
    
    
    m = zeros(1,num_cells);
    m(cIDs((center_frames == frame))) = 1;
    for i = 1:num_cells
        
        mask = make_cell_mask(cells,frame,cells(i).stackID,input);
        this_frame(mask) = m(frame);
        
    end
    
    
    
end

end
