function array = stics2array(vector,transpose)
%STICS2ARRAY Converts the cell-structure of STICS output to 4D numerical
%array.
%
% SYNOPSIS: stics_array = stics2array(stics_img,'on');
% 
% INPUT: stics_img - output of STICS calcuations, should be index by:
%                 stics_img{t}(x,y,1)
%        transpose - 'on'/'off' to transpose y and x (default off)
%
% OUTPUT: array - indices given by:
%                         (t,y,x,1/2) - default behavior
%                         (t,x,y,1/2)
%
% xies@mit Jan 2012

T = numel(vector);
[n,m,~] = size(vector{1});
array = zeros(T,n,m,2);

for i = 1:T
    array(i,:,:,:) = vector{i};
end
if ~exist('transpose','var'), transpose = 'off'; end
if strcmpi(transpose,'on')
    array = permute(array,[1 3 2 4]);
end

end