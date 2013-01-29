function this_Y = split_embryo(Y,c,which)

[num_frames,num_cells] = size(Y);

this_Y = zeros(num_frames,numel(c(c==which)));
this_Y = Y(:,c==which);

end