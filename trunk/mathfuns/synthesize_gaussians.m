function y = synthesize_gaussians(x,params)

y = zeros(size(x));
for i = 1:size(params,2)
    y = y + lsq_gauss1d(params(:,i),x);
end