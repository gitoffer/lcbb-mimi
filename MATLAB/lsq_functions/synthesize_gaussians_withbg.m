function y = synthesize_gaussians_withbg(params,x)

y = lsq_exponential(params(:,1),x);

for i = 2:size(params,2)
    y = y + lsq_gauss1d(params(:,i),x);
end

end
% 
% y = feval(bg_fun,params(1:Nbgparam),x);
% for i = 1:num_gauss
%     
%     startIdx = Nbgparam + 1 + 3*(i-1);
%     
%     y = y + lsq_gauss1d(params(startIdx:startIdx + 2),x);
%     
% end