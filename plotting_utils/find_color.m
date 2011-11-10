function [C] = find_color(value,mini,maxi,N)

error(nargchk(3, 4, nargin))
if maxi<mini
    error('Min bigger than max.');
end
if nargin < 4
    N = 256;
end

ColorSet = jet(N);

if value >= maxi
    C = ColorSet(N,:);
elseif value <= mini
    C = ColorSet(1,:);
else
    color_range = mini:(maxi-mini)/(N-1):maxi;
    z = abs(color_range-value);
    [i] = find(min(z) == z);
    C = ColorSet(i,:);
end
