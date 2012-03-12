function [b,log_post_likelihood] = fit_get_posterior_Mpeaks(data,x,handles)

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

[b,chi_min,~,~,~,~,J] = ...
    lsqcurvefit(@(params,x) construct_mpeaks(x,params,handles), ...
    param_guess,x,data,lb,ub);

prior_volume = Amax*(xmax-xmin);
hessian = inv(J'*J);

log_post_likelihood = log(factorial(M)) + M*log(6*pi) ...
    - M*log(prior_volume) - 1/2*log(abs(det(hessian))) - chi_min^2/2;

if isnan(log_post_likelihood) || isinf(log_post_likelihood)
    log_post_likelihood = -Inf;
end

end