function dist = lmi_dist(a,B)
%MUTINFO Calculates the mutual information between random variables A and B
%
% SYNPOSIS: MI = mutinfo(X,Y);
%
% INPUT: A- DxN array, where D is the dimensionality and N the number of observations
%				 B- DxM array
%		     nA/B (opt) - number of bins for calculating A/B distribution
%
% xies@mit May 2012

% switch nargin
%     case 2
%         nA = 10;
%         nB = 10;
%     case 4
%     otherwise
%         error('Please enter 2 or 4 inputs.');
% end

[N,~] = size(B);
dist = zeros(1,N);
for i = 1:N
   dist(i) = linear_mutinfo(a,B(i,:));
end

end