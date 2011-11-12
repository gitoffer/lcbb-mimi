function [C,R] = get_scf4stics(stics_img,Xf,Yf,stics_o,options)

time_avg = options{1};
local_norm = options{2};
mean_subtract = options{3};

flat = @(x) x(:);
T = numel(stics_img);
centroids = grid2list(Xf(:),Yf(:));
nbins = 25;

C = zeros(T,nbins);
for i = 1:T
    i
    V = stics_img{i};
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    tic
    [C(i,:),R] = spatial_correlation_function(V,centroids,nbins,local_norm,mean_subtract);
    toc
end

R = R*stics_o.um_per_px;
if strcmpi(time_avg,'on'), C = nanmean(C,1); end
