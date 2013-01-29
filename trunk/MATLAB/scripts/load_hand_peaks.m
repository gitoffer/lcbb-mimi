file = '~/Documents/MATLAB/EDGE/DATA_OUTPUT/2color_4 013012/';

peaks_hand = zeros(num_frames,num_cells);

for i = 2:num_frames
    data = load([file num2str(i)]);
    peaks_hand(i,data.cell_indices) = 1;
end

