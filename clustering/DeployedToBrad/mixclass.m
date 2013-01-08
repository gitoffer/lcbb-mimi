function [clabs, err] = mixclass(data,pies,mus,vars)

% MIXCLASS  Get the classification from a mixture model.
%
%   [CLABS,ERR] = MIXCLASS(DATA,WGTS,MUS,VARS)
%
%   For a given set of DATA (nxd) and a mixture model given by
%   WGTS (weights), MUS (component means), and VARS (component
%   variances), return the class labels in CLABS, along with
%   the associated classification error in ERR.
%

%   Model-based Clustering Toolbox, January 2003


% set up the space for the output vectors.
[n,d] = size(data);
err = zeros(1,n);
clabs = zeros(1,n);
for i = 1:n     
    posterior = postm(data(i,:)',pies,mus,vars);
    [v, clabs(i)] = max(posterior);     % classify it with the highest posterior prob.
    err(i) = 1 - v;     % Classification error is 1 - posterior
end

%%%%%%%%%%%%FUNCTION - POSTM %%%%%%%%%%%%%%%%%%%%%%
function posterior = postm(x,pies,mus,vars)
nterms = length(pies);
totprob=0;
posterior=zeros(1,nterms);
for i=1:nterms	%loop to find total prob in denominator (hand, pg 37)
  posterior(i)=pies(i)*evalnorm(x',mus(:,i)',vars(:,:,i));
  totprob=totprob+posterior(i);
end
posterior=posterior/totprob;


%%%%%%%%%%%%%%%  FUNCTION EVALNORM %%%%%%%%%%%%%
function prob = evalnorm(x,mu,cov_mat);
[n,d]=size(x);
prob = zeros(n,1);
a=(2*pi)^(d/2)*sqrt(det(cov_mat));
covi = inv(cov_mat);
for i = 1:n
	xc = x(i,:)-mu;
	arg=xc*covi*xc';
	prob(i)=exp((-.5)*arg);
end
prob=prob/a;
