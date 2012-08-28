function data = stitch_embryos(data,input)

num_embryos = numel(data);
left = [input.tref];
for i = 1:num_embryos
    right(i) = size(data{i},1) - left;
end

max_left = max(left);
max_right = max(right);

for i = 1:num_embryos
    
    this_data = data{i};
    num_cells = size(this_data,2);
    this_data = padarray(this_data,[max_left - left(i), num_cells],NaN);
    this_data = padarray(this_data,[max_right - right(i), num_cells],NaN); 
    
end

