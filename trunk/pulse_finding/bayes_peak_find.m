function [P parameters] = bayes_peak_find(data,x,Mmax,handles)
%BAYES_PEAK_FIND Uses a Bayesian multiple hypothesis testing framework to
% iteratively fit many peaks (of a given form) to a signal in the presence
% of a background signal. Will return the posterior probability of each
% model as well as its parameters. The prior parameter distribution is
% assumed to be uniform over the given parameter bounds; there is also
% uniform prior over the models.
%
% INPUT: data - signal to be fitted
%        x - the domain of the signal
%        Mmax - the maximum number of peaks to be ranked
%        handles
%               .peak_function - function handle for the peak form
%               .background_function - background function handle
%               .num_params - array of the number of parameters needed for
%                             the peak function and then the bg function
%               .parameter_bounds - [Amax, xmin, xmax]
%                                   [max height, minimum peak location, max
%                                    peak location]
%
% OUTPUT: P - posterior probabilities
%         parameters - a cell array of parameters
%
%
% Reference:
% Sivia, D.S. Data Analysis: A Bayesian Tutorial. 2nd ed. Oxford Science
% Publications (2006).
%
% xies @ mit. Mar 2012.

likelihoods = zeros(1,Mmax);
parameters = cell(1,Mmax+1);
for i = 0:Mmax
    [peak_guesses,peak_lb,peak_ub] = estimate_initial_peaks(data,i);
    [bg_guess,bg_lb,bg_ub] = estimate_background_peak(data,handles);
    handles.initial_guess = [peak_guesses, bg_guess];
    handles.lb = [peak_lb bg_lb];
    handles.ub = [peak_ub bg_ub];
    
    [b, log_post_likelihood] = fit_get_posterior_Mpeaks(data,x,handles);
    
    likelihoods(i+1) = log_post_likelihood;
    parameters{i+1} = b;
    display(['Finished fitting ' num2str(i) '-peak model.']);
end

% NEED TO MARGINALIZE over background variables

% Convert to log-differences for numerical stability
% log_diffs = likelihoods(ones(1,Mmax+1),:) - likelihoods(ones(1,Mmax+1),:)';
% P = 1./sum(exp(log_diffs),2);
% P(isnan(P) | isinf(P)) = 0;

P = assign_probability(likelihoods);

end
