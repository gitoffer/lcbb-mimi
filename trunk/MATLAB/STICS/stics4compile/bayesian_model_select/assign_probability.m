function probabilities  = assign_probability(log_likelihoods)
%ASSIGN_PROBABILITY Assign probabilities given a set of log-likelihoods;
% will calculate log-differences for numerical stability.
%
% SYNOPSIS: P = assign_probabilities(log_likelihoods);
% INPUT: log_likelihoods - an array of log-likelihoods
% OUTPUT: probabilities - an array of probabilities
%
% xies@mit March 2012


N = length(log_likelihoods);
if ~isrow(log_likelihoods);
    log_likelihoods = log_likelihoods';
end

% Construct a matrix of log-differences
log_diffs = log_likelihoods(ones(1,N),:) - log_likelihoods(ones(1,N),:)';

% Add up all the exponentiated differences
probabilities = 1./sum(exp(log_diffs),2);

% If there are NaN or Inf probabilities, set to 0
probabilities(isnan(probabilities) | isinf(probabilities)) = 0;
