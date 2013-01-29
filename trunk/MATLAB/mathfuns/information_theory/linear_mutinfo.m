function r = linear_mutinfo(A,B)
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

[N,d] = size(A);

if any(size(A) ~= size(B)), error('The two random variables must have the same dimensionality.i'); end

C_a = nanvar(A); % martinal covariance
C_b = nanvar(B); % martinal covariance
C_ab = nancov(A,B); % pairwise covariance

MI = 0.5*(log(det(C_a)) + log(det(C_b)) - log(det(C_ab)));

r = sqrt(1-exp(-2*MI/d));

end