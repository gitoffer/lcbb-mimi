function y = construct_mpeaks(x,params,handles)
%CONSTRUCT_M_PEAKS

p = numel(params);
pk_fun = handles.peak_function;
bg_fun = handles.background_function;
pk_num_params = handles.num_parameter(1);
bg_num_params = handles.num_parameter(2);
M = (p-bg_num_params)/pk_num_params;

bg_params = params(end-bg_num_params+1:end);
y = feval(bg_fun,bg_params,x);

for i = 1:M
    amp = params((i-1)*pk_num_params+1);
    mu = params((i-1)*pk_num_params+2);
    sigma = params((i-1)*pk_num_params+3);
    y = y + feval(pk_fun,[amp mu sigma],x);
end

end
