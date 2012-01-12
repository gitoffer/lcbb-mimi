function data = load_stack4manifold(filebase,t,im_params,tstr,zstr,cstr)
%LOAD_STACK4MANIFOLD

myo_ch = zeros(im_params.X,im_params.Y,im_params.Z);
mem_ch = myo_ch;
for j = 1:Z
	this_myo = sprintf('%s%s%00d%s%00d%s%00d', ...
		filebase,tsrt,t,zstr,j-1,cstr,im_params.myo_ch);
	this_myo = sprintf('%s%s%00d%s%00d%s%00d', ...
		filebase,tsrt,t,zstr,j-1,cstr,im_params.mem_ch);
	myo_ch(:,:,j) = imread(this_myo);
	mem_ch(:,:,j) = imread(this_mem);
end

data{1} = myo_ch;
data{2} = mem_ch;

end
