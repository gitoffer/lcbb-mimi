function tiff_sequence_write(stack,name_base)

[~,~,num_frames,channels] = size(stack);

for i = 1:num_frames
    for j = 1:channels
        name = sprintf('%s%s%03d%s%03d%s',name_base,'_t',i,'_z',j,'.tif');
        imwrite(stack(:,:,i,j), name);
    end
end
