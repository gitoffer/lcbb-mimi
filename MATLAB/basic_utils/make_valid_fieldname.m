function cell_str = make_valid_fieldname(cell_str)
%MAKE_VALID_FIELDNAME Takes in a cell of strings, and replaces all hyphens
% or spaces with an underscore (_), and all # signs with the words
% 'number'. The output should be valid for use as fieldnames in a
% structure.
%
% xies@mit.edu December 2011.

cell_str = strrep(cell_str,'-','_');
cell_str = strrep(cell_str,' ','_');
cell_str = strrep(cell_str,'#','number');

end