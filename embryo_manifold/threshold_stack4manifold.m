function local_thresholds = threshold_stack4manifold(imstack,params)
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


wx = params.wx; wy = params.wy; perc = params.perc;
prefilter = params.prefilter; display = params.display;

[Y,X,Z] = size(imstack);
support = 2*1024; % Support for filter
wx_p2 = nextpow2(wx);
wy_p2 = nextpow2(wy);

% Pre-filter image
if prefilter
    for i = 1:Z
        imstack(:,:,i) = gaussian_bandpass(imstack(:,:,i),support,prefilter,0);
    end
end

% Get number of local 'windows'
Nx = X/wx_p2;
Ny = Y/wy_p2;

x_bottom = ((1:Nx)-1)*wx_p2 + 1;
x_top = x_bottom + wx_p2 - 1;
y_bottom = ((1:Ny)-1)*wy_p2 + 1;
y_top = y_bottom + wy_p2 - 1;

% get if of for-loop?
local_thresholds = zeros(Y,X);
for i = 1:Nx
    for j = 1:Ny
		% Crop out a wx x wy x Z section
        
        v = imstack(y_bottom(j):y_top(j),x_bottom(i):x_top(i),:);
		% Generate a histogram of all pixel values
        [counts,intensity] = hist(v(:),params.bin_number);
		% Generate CDF
        CDF = cumsum(counts);
        CDF = CDF/max(CDF(:));
		% Find threshold by percentile
        local_thresholds(y_bottom(j):y_top(j),x_bottom(i):x_top(i)) = ...
            intensity(find(CDF > 1-perc/100,1,'first'));
    end
end

if strcmpi(display,'on')
    figure(5); clf; imagesc(local_thresholds);colorbar;
end

local_thresholds = gaussian_bandpass(local_thresholds,support,params.filter_size,0);
% local_thresholds = local_thresholds(1:Y,1:X)./params.bit_depth; % ?

if strcmpi(display,'on')
    figure(6); clf; imagesc(local_thresholds);colorbar;
    title('Local threshold values')
end

end
