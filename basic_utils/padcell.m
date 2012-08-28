function cell_pad = padcell(cell_in,num_pad,val,dir)

[num_frames,num_cells] = size(cell_in);

cell_pad = cell(num_frames + num_pad,num_cells);

if strcmpi(dir,'pre')
    cell_pad(1:num_pad,:) = {NaN};
    cell_pad((num_pad + 1):(num_frames + num_pad),:) = cell_in;
end
if strcmpi(dir,'post')
    cell_pad((num_frames + 1):(num_frames + num_pad),:) = {val};
    cell_pad(1:num_frames,:) = cell_in;
end

end