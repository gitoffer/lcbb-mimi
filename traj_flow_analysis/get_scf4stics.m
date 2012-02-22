function [C,R] = get_scf4stics(stics_img,Xf,Yf,dR,Rmax,stics_o,options)

time_avg = options.time_avg;
local = options.local;
mean_subt = options.mean_subt;
nbins = numel(0:dR:Rmax);

flat = @(x) x(:);
T = numel(stics_img);
centroids = grid2list(Xf(:),Yf(:));

C = zeros(T,nbins);
for i = 1:T
    V = stics_img{i};
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    tic
    [C(i,:),R] = spatial_correlation_function(V,centroids,dR,Rmax,options);
    toc
end

R = R*stics_o.um_per_px;
if strcmpi(time_avg,'on'), C = nanmean(C,1); end

end