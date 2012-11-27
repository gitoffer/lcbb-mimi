function [params,fits,residuals] = fit_response(responses,opt)

num_pulses = numel(pulse);
lsqfun = opt.fun;
lb = opt.lb;
ub = opt.ub;
guess = opt.guess;
time = opt.t;

fits = zeros(size(responses));

for i = 1:size(responses,1)
	this_resp = responses(i,:);
	[p,~,residuals] = lsqcurvefit(lsqfun,t,this_resp,guess,lb,ub);
	fit(i,:) = feval(lsqfun,p,t);

	
end



end
