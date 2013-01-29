function [B Xf Yf] = stics_image_bayes(imser,o,bayes_opt, varargin)
% compute stic funcion for every grid point of a rectanglular meshgrid
% specified by dx, dy,(point spcacing) wx, wy(window size)

dx = o.dx;
dy = o.dy;
wx = o.wx;
wy = o.wy;

if isempty(varargin)
%     fitTimeLimit = corrTimeLim;
    showsurf = 'off';
elseif numel(varargin)==1
%     fitTimeLimit = varargin{1};
    showsurf = 'off';
else
%     fitTimeLimit = min(varargin{1},corrTimeLim);
    showsurf = varargin{2};
end

% specify meshgrid with dx, dy, wx, wy,
xbegin = max(ceil(dx/2),ceil(wx/2));
ybegin = max(ceil(dy/2),ceil(wy/2));
xend = size(imser,2) - max(ceil(dx/2),ceil(wx/2));
yend = size(imser,1) - max(ceil(dy/2),ceil(wy/2));
if xbegin<=xend && ybegin<=yend
    [Xf Yf] = meshgrid(xbegin: dx: xend, ybegin: dy: yend);
elseif xbegin>xend && ybegin<=yend
    [Xf Yf] = meshgrid(xbegin, ybegin: dy: yend);
elseif xbegin<=xend && ybegin>yend
    [Xf Yf] = meshgrid(xbegin: dx: xend, ybegin);
end

%call stics_grid
B = stics_grid_bayes(imser,Xf, Yf, o, bayes_opt, o.corrTimeLim,showsurf);