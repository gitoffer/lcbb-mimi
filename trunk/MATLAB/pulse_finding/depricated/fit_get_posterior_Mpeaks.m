function [b,log_post_likelihood] = fit_get_posterior_Mpeaks(data,x,handles)
%FIT_GET_POSTERIOR_MPEAKS Fits the data to M peaks and returns the fitted
% parameters and posterior likelihood, given uniform prior distribution of
% parameters.
%
% SYNOPSIS: [b,likelihood] = fit_get_posterior_Mpeaks(y,x,handles)
% INPUT: y
%
% xies@mit.edu. Mar 2012.

if ~isrow(data) ,data = data'; end % Ensure row-vectors


pk_num_params = handles.num_parameter(1);
bg_num_params = handles.num_parameter(2);
param_guess = handles.initial_guess;
p = numel(param_guess);
M = (p-bg_num_params)/pk_num_params;
Amax = deal(handles.parameter_bounds(1));
xmin = deal(handles.parameter_bounds(2));
xmax = deal(handles.parameter_bounds(3));
param_guess = handles.initial_guess;
lb = handles.lb;
ub = handles.ub;

o = optimset('display','off'); %suppress OPTIM output

[b,chi_min,~,flag,~,~,J] = ...
    lsqcurvefit(@(params,x) construct_mpeaks(x,params,handles), ...
    param_guess,x,data,lb,ub,o);

prior_volume = Amax*(xmax-xmin);
if rcond(full(J'*J)) < 2e-8 || flag <= 0
    log_post_likelihood = -Inf;
else
    hessian = inv(J'*J);
    
    log_post_likelihood = log(factorial(M)) + M*log(6*pi) ...
        - M*log(prior_volume) - 1/2*log(abs(det(hessian))) - chi_min/2;
    
    if isnan(log_post_likelihood) || isinf(log_post_likelihood)
        log_post_likelihood = -Inf;
    end
    
end
end