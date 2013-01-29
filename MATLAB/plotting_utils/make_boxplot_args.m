function [X,G] = make_boxplot_args(varargin)
%MAKE_BOXPLOT_ARGS Constructs the inputs to BOXPLOT. Will linearize and
% contatenate all inputs and make a corresponding grouping array.
%
% USAGE: [X,G] = make_boxplot_args(A,B,C,...)
%
% xies@mit.edu

if nargin < 1, error('No argument!'); end

flat = @(x) x(:);
arg_array = varargin;
arg_array = cellfun(flat,arg_array,'UniformOutput',false);
X = cat(1,arg_array{:});

G = cell(numel(X),1);
num_elements = cellfun(@numel,arg_array);
num_talley = [1 cumsum(num_elements)];
for i = 1:numel(num_elements)
    [G{num_talley(i):num_talley(i+1)}] = deal(num2str(i));
end