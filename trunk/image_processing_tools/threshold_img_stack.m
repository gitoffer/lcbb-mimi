function local_thresholds = threshold_img_stack(imstack,Lxx,Lyy,perc,filter,display)

if ~exist('filter','var')
    filter = 'on';
end

[X,Y,Z] = size(imstack);
support = 2*max(X,Y);
Lx = nextpow2(Lxx);
Ly = nextpow2(Lyy);

if filter
    for i = 1:Z
        [imstack(:,:,i),~] = uint8(gaussian_filter(imstack(:,:,i),support,1,0));
    end
end

Nx = X/Lx;
Ny = Y/Ly;

x = (1:Nx)*Lx + 1;
y = (1:Ny)*Ly + 1;

local_thresholds = zeros(X,Y);
for i = 1:Nx
    for j = 1:Ny
        v = imstack(x(i):x(i) + Lx - 1, y(j):y(j) + Ly - 2, :);
        counts = hist(v(:),1:2^12-1);
        CDF = cumsum(counts);
        CDF = CDF/max(CDF(:));
        local_thresholds(x(i):x(i) + Lx - 1, y(i):y(i) + Ly - 1) = ...
            find(CDF > perc/100,1,'first');
    end
end

if strcmpi(display,'on')
    figure(5); clf; imagesc(thresholded);
end

local_thresholds = gaussian_filter(thresholded,support,20,0);
local_thresholds = local_thresholds(1:X,1:Y);

if strcmpi(display,'on')
    figure(6); clf; imagesc(local_thresholds);
end

%get a location dependent absolute-intensity cutoff 
%using a relative-intensity cutoff "top "-percent 
%absolute cutoff is determined from small compartments 

%Discrete threshold array is smoothened at the end

%raw=raw data array e.g. myosin
%Lxx Lyy size of compartment
%top relative intensity threshold
%remove_spurious=1 filters structures<3pixels, =0 ->no filtering
