function [out_data,t] = stitch_embryos(data,input)
%STITCH_EMBRYOS Pad data from different embryos with NaN blocks so they can
% be put into the same matrix. If given, will use a input.tref to construct
% a developmental time vector to keep track of the aligned-time associated
% with each frame in each cell.
%
% USAGE: [stitched_data,t] = stitch_embryo(data,input_structure)
%
% INPUT: data - 1xN cell-array of the same measurement from N different
%		 		embryos
% 		 input - 1xN array of the INPUT structure constructed in
%				 LOAD_EDGE_SCRIPT
%
% OUTPUT: stitched_data - a NxT array/(cell-array) of collated data
% 		  t - NxT array of corresponding aligned time
%
% xies@mit.edu

%STITCH_EMBRYOS Stitches embryos together using the TREF (reference frame)
% as provided in the INPUT structure (input.tref). Does not account for
% framerate differences, but will record the 'aligned-time' associated with
% each frame in each cell.
%
% SYNOPSIS: [stitched_data,t] = stitch_embryos(data,input);
%
% xies@mit.

num_embryos = numel(data);
if all([input.fixed])
    num_frames = 1;
else
    num_frames = cellfun(@(x) size(x,1), data);
end
max_num_frames = max(num_frames);


% Preallocate
t = nan( num_embryos , max_num_frames );
% max_tref = max( [input.tref] );
% lags = max_tref - [input.tref];

out_data = [];
for i = 1:num_embryos

    this_data = data{i};
    
	% Construct the time vector using the framerates
	t(i,1:num_frames(i)) = ( (1 : num_frames(i)) - input(i).tref ).*input(i).dt;

	if iscell( data{i} )
		this_data = padcell( this_data, max_num_frames - num_frames(i), ...
			NaN, 'post');
	else
		this_data = padarray( this_data, max_num_frames - num_frames(i), ...
			NaN, 'post');
	end

	out_data = cat(2, out_data, this_data);

end


% out_data = [];
% for i = 1:num_embryos
%     
%     this_data = data{i};
% 
%     if iscell(data{i})
%         this_data = padcell(this_data,max_left - left(i),NaN,'pre');
%         this_data = padcell(this_data,max_right - right(i),NaN,'post');
%     else
%         this_data = padarray(this_data,max_left - left(i),NaN,'pre');
%         this_data = padarray(this_data,max_right - right(i),NaN,'post');
%     end
% 
%     out_data = cat(2,out_data,this_data);
%     
% end
% 
% time = -(max_left-1):max_right;


% left = [input.tref];
% 
% % Get the 'rightmost' frame
% 
% for i = 1:num_embryos
%     right(i) = size(data{i},1) - left(i);
% end
% 
% max_left = max(left);
% max_right = max(right);

end
