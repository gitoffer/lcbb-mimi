function local_thresholds = threshold_stack4manifold(imstack,params,prefilter,display)
%THRESHOLD_STACK4MANIFOLD
% Makes a thresholded myosin stack by looking in wx x wx x Z 'supervoxel'
% pixel intensity distributions and taking the specified top percentile
% pixels in that local window.
%
% SYNOPSIS: img_th = threshold_stack4manifold(imstack,params,1,'on')
%
% INPUT: imstack - image stack to threshold (x,y,z)
%		 params.wx - local thresholding window in x
%		 	   .wy - local thresholding window in y
%	           .perc - percentiles to keep
%			   .filter_size - final smoothing filter size
%							 
%        prefilter - (optional), kernel size for pre-filter the image
%                    stack,
%                    usually to remove PSF noise (default = 0)
%        display - 'on'/'off' display results (default 'off')
%
% OUTPUT: local_thresholds - the threshold values (2D)
%
% xies @ mit. jan 2012.

if ~exist('filter','var')
    prefilter = 0;
    display = 'off';
end

wx = params.wx; wy = params.wy;

[X,Y,Z] = size(imstack);
support = 2*max(X,Y); % Support for filter
wx_p2 = nextpow2(wx);
wy_p2 = nextpow2(wy);

% Pre-filter image
if prefilter
    for i = 1:Z
        [imstack(:,:,i),~] = uint8(gaussian_filter(imstack(:,:,i),support,prefilter,0));
    end
end

% Get number of local 'windows'
Nx = X/wx_p2;
Ny = Y/wy_p2;

x_bottom = ((1:Nx)-1)*wx_p2 + 1;
x_top = x_bottom + wx_p2 - 1;
y_bottom = ((1:Ny)-1)*wy_p2 + 1;
y_top = y_bottom + wy_p2 + 1;

% get if of for-loop?
local_thresholds = zeros(X,Y);
for i = 1:Nx
    for j = 1:Ny
		% Crop out a wx x wy x Z section
        v = imstack(x_bottom(i):x_top(i), y_bottom(j):y_top(j),:);
		% Generate a histogram of all pixel values
        counts = hist(v(:),params.bit_depth);
		% Generate CDF
        CDF = cumsum(counts);
        CDF = CDF/max(CDF(:));
		% Find threshold by percentile
        local_thresholds(x_bottom(i):x_top(i), y_bottom(i):y_top(i)) = ...
            find(CDF > params.perc/100,1,'first');
    end
end

if strcmpi(display,'on')
    figure(5); clf; imagesc(local_thresholds);
end

local_thresholds = gaussian_filter(local_thresholds,support,params.filter_size,0);
local_thresholds = local_thresholds(1:X,1:Y); % ?

if strcmpi(display,'on')
    figure(6); clf; imagesc(local_thresholds);
end

end
