function [params,fit,residuals] = fit_response(response,opt)
%FIT_RESPONES
%
% SYNOPSIS: [params,fit,residuals] = fit_response(response,opt);

lsqfun = opt.fun;
lb = opt.lb;
ub = opt.ub;
guess = opt.guess;
time = opt.t;

o = optimset('display','off');

[params,~,residuals] = lsqcurvefit(lsqfun,guess,time,response,lb,ub,o);
fit = feval(lsqfun,params,time);

end
