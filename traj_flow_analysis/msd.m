function g = msd(x_pos,y_pos,display)
%MSD Calculates the mean-squared displacement
%
% SYNOPSIS: g = msd(x_pos,y_pos,display)
%
% INPUT: x_pos - x positions
%        y_pos - y positions
%        display - 'on'/'off' plots the MSD (Default off)
%
% xies@mit.edu 10/2011.


[T,N] = size(x_pos);
if T < 20, warning('msd:tracklength_too_small',...
        'Track length (%d) is too small for accurate MSD calculation.',N); end
if ~any(size(x_pos) == size(y_pos)), error('X and Y must have the same size'); end

g = zeros(T,N);
for i = 1:T
    g(i,:) = nanmean((x_pos(i:T-1,:)-x_pos(1:T-i,:)).^2 + (y_pos(i:T-1,:)-y_pos(1:T-i,:)).^2,1);
end

if ~exist('display','var'),display = 'off'; end
if strcmpi(display,'on')
    plot(g);
    title('MSD')
    xlabel('Tau')
end