function [C,T] = get_tcf4stics(stics_img,dt,tmax,stics_opt,options)


V = stics2array(stics_img);
tic
[C,T] = temporal_correlation_function(V,dt,tmax,options);
toc

T = T*stics_opt.sec_per_frame/60;
