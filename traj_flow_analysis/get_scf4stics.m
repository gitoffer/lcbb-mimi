function [C,R] = get_scf4stics(stics_img,Xf,Yf,stics_o,time_avg)

flat = @(x) x(:);
T = numel(stics_img);
centroids = grid2list(Xf(:),Yf(:));
nbins = 25;

C = zeros(T,nbins+1);
for i = 1:T
    i
    V = stics_img{i};
    V = grid2list(flat(V(:,:,1)),flat(V(:,:,2)));
    [C(i,:),R] = spatial_correlation_function(V,centroids,nbins);
end

R = R*stics_o.um_per_px;
if strcmpi(time_avg,'on'), C = nanmean(C,1); end
