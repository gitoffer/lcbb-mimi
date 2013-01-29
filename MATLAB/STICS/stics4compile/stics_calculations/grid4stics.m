function [Xf Yf] = grid4stics(imser,dx, dy, wx, wy) 
% compute stic funcion for every grid point of a rectanglular meshgrid 
% specified by dx, dy,(point spcacing) wx, wy(window size)

% and below done with "stics_grid"
% fitting stic func to 2d gaussian to track peak position
% fitting peak position vs time to obtain velocity, plot velocity vector on the first image
% varargin{1}=fitting limit; varargin{2}= whether show stic func (on/off)
% Jun He, @MIT, Jan 16, 2010


% specify meshgrid with dx, dy, wx, wy,
xbegin = max(ceil(dx/2),ceil(wx/2));
ybegin = max(ceil(dy/2),ceil(wy/2));
xend = size(imser,2) - max(ceil(dx/2),ceil(wx/2));
yend = size(imser,1) - max(ceil(dy/2),ceil(wy/2));


if xbegin<=xend & ybegin<=yend 
[Xf Yf] = meshgrid(xbegin: dx: xend, ybegin: dy: yend);
elseif xbegin>xend & ybegin<=yend 
[Xf Yf] = meshgrid(xbegin, ybegin: dy: yend);
elseif xbegin<=xend & ybegin>yend 
[Xf Yf] = meshgrid(xbegin: dx: xend, ybegin);
else error('blah');
end

end