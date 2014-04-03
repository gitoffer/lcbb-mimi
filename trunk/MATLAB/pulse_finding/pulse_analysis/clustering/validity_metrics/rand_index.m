function [RI,ARI] = rand_index(c1,c2)
%RAND_INDEX Calculates the Rank index and adjusted Rank index between two
% clusterings of a set of data.
%
% SYNOPSIS: [RI, ARI] = rand_index(c1,c2);
%
% INPUT: c1 - cluster labels from the first clustering
%        c2 - cluster labels from the second clustering
% OUTPUT: RI - the Rand index
%         ARI - the Rand index adjusted for chance
%
% xies@mit.edu

if nargin < 2, error('Requires two input arguments.'); end
if any(size(c1) ~= size(c2))
    error('The input vectors need to be the same');
end

N = numel(c1);
numc1 = max(c1); numc2 = max(c2);

% Construct a 2D histogram (contingency table)
C = zeros(numc1,numc2);
for i = 1:N
    C(c1(i),c2(i)) = C(c1(i),c2(i)) + 1;
end

sum_row = sum(sum(C,2).^2);
sum_col = sum(sum(C,1).^2);
sum_sq = sum(sum(C.^2));

num_pair = nchoosek(N,2);

% Rand index
% Number of agrees
num_agree = num_pair + sum_sq - (sum_row + sum_col)/2;
num_disagree = num_pair - num_agree;

RI = num_agree/num_pair;

% Adjusted index

expected_index = (N*(N^2+1) ...
    - (N+1)*sum_row - (N+1)*sum_col ...
    + 2*(sum_row*sum_col)/N)/(2*(N-1));

ARI = (num_agree - expected_index)/(num_pair - expected_index);
if isinf(ARI), ARI = 0; end

end