function output = stacf_test(G_th,N,noise_level,xdata,lsq_opt,stics_o,bayes_o)
%% Generate theoretical and simulated curves (i.e. synthesize data)

G_sim = zeros([size(G_th) 4]);
for i = 1:N
    G_sim(:,:,:,i) = add_unif_noise(G_th,noise_level);
end

STCorr = mean(G_sim,4);
STVar = var((G_sim),0,4);

%% Set up the appropriate model hypotheses

% Idea: associate model with a structure for better handling of params and
% statistics thereof.

num_models = numel(bayes_o.model_list);

for i = 1:num_models
    input.Model = bayes_o.model_list{i};
    display('.')
    display(['Evaluating the ' input.Model '.'])
    input.xdata = xdata;
    foo = estimate_initial_params(STCorr,input,stics_o,bayes_o.photobleaching);
    input.InitParams = foo{1};
    input.LowerBound = foo{2};
    input.UpperBound = foo{3};
    output(i) = fit_model_calc_bayes(...
        STCorr,STVar,input,lsq_opt,stics_o,bayes_o);
end

output = assign_probability(output);

for i = 1:num_models
    display(['The model probability for ' output(i).model_name ' is ' ...
        num2str(output(i).model_probability)]);
end
end