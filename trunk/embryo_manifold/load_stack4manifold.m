function data = load_stack4manifold(io,im_params,t)
%LOAD_STACK4MANIFOLD Use from manifold_control.m
%
% SYNOPSIS: data = load_stack4manifold(io,im_params,t);
%
% xies@mit.edu Jan 2012

filebase = [io.path,io,file];

myo_ch = zeros(im_params.X,im_params.Y,im_params.Z);
mem_ch = myo_ch;
for j = 1:Z
	this_myo = sprintf('%s%s%00d%s%00d%s%00d', ...
		filebase,io.tsrt,t,io/zstr,j-1,io.cstr,im_params.myo_ch);
	this_mem = sprintf('%s%s%00d%s%00d%s%00d', ...
		filebase,io.tsrt,t,io.zstr,j-1,io.cstr,im_params.mem_ch);
	myo_ch(:,:,j) = imread(this_myo);
	mem_ch(:,:,j) = imread(this_mem);
end

data{1} = myo_ch;
data{2} = mem_ch;

end
