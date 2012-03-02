function y = synthesize_gaussians(x,params)

y = zeros(size(x));
for i = 1:size(params,2)
    y = y + gauss1d(params(:,i),x);
end