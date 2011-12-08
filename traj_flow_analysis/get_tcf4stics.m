function [C,T] = get_tcf4stics(stics_img,dt,tmax,stics_opt,options)

V = zeros([length(stics_img),size(stics_img{1})]);
for i = 1:numel(stics_img)
    V(i,:,:,:) = stics_img{i};
end
tic
[C,T] = temporal_correlation_function(V,dt,tmax,options);
toc

T = T*stics_opt.sec_per_frame/60;
