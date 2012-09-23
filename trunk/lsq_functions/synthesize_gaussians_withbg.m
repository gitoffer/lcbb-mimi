function y = synthesize_gaussians_withbg(params,x)

y = lsq_exponential(params(:,1),x);
for i = 2:size(params,2)
    y = y + lsq_gauss1d(params(:,i),x);
end

end