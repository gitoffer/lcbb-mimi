function stics_avg = line_average_stics(stics_img,dir)
%LINE_AVERAGE_STICS Takes the average of a STICS vector field along a
%'line' of vectors in the specified direction.
%
% SYNOPSIS: line_average_stics(vector,direction);
%
% INPUT: VECTOR - The output of STICS
%        direction - X or Y (the direction along which the function will
%        take an average)
% OUTPUT: STICS_AVG - vector field means
%
% xies@mit Dec 2011.

if ~exist('dir','var'), which = 2;
else
    if strcmpi('dir','x'), which = 2;
    else which = 1;
    end
end

T = numel(stics_img);
stics_avg = cell(1,T);
for i = 1:T
    avg_vx = nanmean(stics_img{i}(:,:,1),which);
    avg_vy = nanmean(stics_img{i}(:,:,2),which);
    stics_avg{i} = cat(3,avg_vx,avg_vy);
end

end