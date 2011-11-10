function cell_str = make_valid_fieldname(cell_str)

cell_str = strrep(cell_str,'-','_');
cell_str = strrep(cell_str,' ','_');
cell_str = strrep(cell_str,'#','number');