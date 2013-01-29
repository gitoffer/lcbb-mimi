function label_mat = make_matrix_block_lines(block_labels,dir)
%MAKE_MATRIX_BLOCK_LINES Make lines between the blocks of a matrix. To be
% used for labelling half a heatmap (e.g.  symmetric interaction map).
% 
% USAGE: label_mat = make_matrix_block_lines(block_labels,dir);
% 
% INPUT: block_labels - a 1XN vector
%        dir - 'l' or 'u' for lower or upper triangle
%
% xies@mit.edu Jan 2013

[X,Y] = meshgrid(block_labels);
N = numel(block_labels);

switch dir
    case 'l'
        label_mat = cat(1,diff(Y,1,1),ones(1,N));
        label_mat(label_mat == 0) = NaN;
    case 'u'
        label_mat = cat(2,diff(X,1,2),ones(N,1));
        label_mat(label_mat == 0) = NaN;
end

end