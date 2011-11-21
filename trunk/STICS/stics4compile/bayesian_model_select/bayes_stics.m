function output = bayes_stics(STCorr,STVar,stics_opt,bayes_opt,play)
%BAYES_STICS Compute bayesian probabilities given STICS correlation and
%STIC variance.
%
% SYNOPSIS: output = bayes_stics(STCorr,STVar,stics_opt,bayes_opt)
% INPUT: STCorr - STICS data to be fitted
%        STVar - variance in STICS data
%        stics_opt - STICS options (window sizes, etc.)
%        bayes_opt - Bayes calculation options (weighted fits, etc.)
% OUTPUT: output - a 1xN array of structures (N = number of competing
%                  models) with fields: model_name
%                                       parameters
%                                       log_likelihood
%                                       model_probability

% Get rid of tau = 0
STCorr = STCorr(:,:,2:end);
% STCorr = STCorr./max(STCorr(:));
STVar = STVar(:,:,2:end);

bg = estimate_background(STCorr);

for t = 1:size(STCorr,3)
    STCorr(:,:,t) = STCorr(:,:,t) - bg(t);
end

%% Check image size to pass to Bayes
xdata(1) = size(STCorr,1); %X direction
xdata(2) = size(STCorr,2); %Y direction
xdata(3) = 1;              %tau0 = 1
xdata(4) = size(STCorr,3); %tauf

%% Fit to models and calculate probability

lsq_opt = optimset('Display','off');
models = bayes_opt.model_list;
num_models = numel(models);
clear output
% output(num_models,1) = BayesModels;

[output(1,num_models).model_name,...
    output(1,num_models).params, ...
    output(1,num_models).log_likelihood,...
    output(1,num_models).model_probability,...
    output(1,num_models).D,...
    output(1,num_models).vx,...
    output(1,num_models).vy]...
    = deal([],[],NaN,NaN,NaN,NaN,NaN);

for i = 1:num_models
    input.Model = models{i};
    input.xdata = xdata;

    foo = estimate_initial_params(STCorr,input,stics_opt,bayes_opt.photobleaching);
    input.InitParams = foo{1};
    input.LowerBound = foo{2};
    input.UpperBound = foo{3};
    %     display(['Calcuating Bayesian model probability for ' input.Model])

    output(i) = fit_model_calc_bayes(...
        STCorr,STVar,input,lsq_opt,stics_opt,bayes_opt);
end

output = assign_probability(output);
output = get_physical_params(output);

end
