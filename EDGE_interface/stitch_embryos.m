function out_data = stitch_embryos(data,input)

num_embryos = numel(data);
left = [input.tref];
for i = 1:num_embryos
    right(i) = size(data{i},1) - left(i);
end

max_left = max(left);
max_right = max(right);

out_data = [];
for i = 1:num_embryos
    
    this_data = data{i};
	
    if strcmpi(class(data{i}),'cell')
        this_data = padcell(this_data,max_left - left(i),NaN,'pre');
        this_data = padcell(this_data,max_right - right(i),NaN,'post');

    else
        this_data = padarray(this_data,max_left - left(i),NaN,'pre');
        this_data = padarray(this_data,max_right - right(i),NaN,'post');
    end

    out_data = cat(2,out_data,this_data);
    
end

end