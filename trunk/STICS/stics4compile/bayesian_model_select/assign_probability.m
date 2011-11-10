function assigned  = assign_probability(unassigned_struct)

assigned = unassigned_struct;
log_likelihoods = [unassigned_struct.log_likelihood];
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
probabilities = num2cell(probabilities);

[assigned.model_probability] = deal(probabilities{:});
