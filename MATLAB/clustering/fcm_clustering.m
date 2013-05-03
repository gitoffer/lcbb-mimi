function [centers,U,obj_func] = fcm_clustering(X,k,varargin)
%FCM_CLUSTERING Fuzzy c-means clustering with custom distance metrics.
%
% SYNOPSIS:[centers,U,J] =
% fcm_clustering(X,num_clust,'distance','euclidean','maxiter',100,'tolerance',1e-5);
% 
% INPUT: X - NxT data matrix, with N samples and T dimensions
%        k - number of clusters
%  OPTION PAIRS:
%  (opt) 'distance'  - see PDIST for possible distance inputs. Default
%                      value is 'euclidean'.
%        'maxiter'   - maxinum iteration number. Default = 100;
%        'tolerance' - tolerance in objective function change.
%                      Default = 1e-8.
%        'weight'    - exponent weight. Default = 2.
%
% xies@mit.edu

% Parse input

%Check for paired option inputs
if mod(numel(varargin),2) ~= 0, error('Please input options in pairs.'); end
tags = varargin(1:2:end);
values = varargin(2:2:end);
% get distance function
which = find(strcmpi(tags,'distance'));
if ~isempty(which)
    dist_fun = values{which};
else
    dist_fun = 'euclidean';
end
% get maxiter
which = find(strcmpi(tags,'maxiter'));
if ~isempty(which), Niter = values{which}; else Niter = 100; end
which = find(strcmpi(tags,'tolerance'));
if ~isempty(which), tol = values{which}; else tol = 1e-8; end
which = find(strcmpi(tags,'weight'));
if ~isempty(which), m = values{which}; else m = 2; end

N = size(X,1);

% Initialize
obj_func = zeros(Niter,1);
U0 = rand(k,N);
U = U0;

% Mail FCM loop
for iter = 1:Niter
    %Calculate center vectors
    centers = U*X;
    centers = bsxfun(@rdivide,centers,sum(U,2));
    
    D = pdist2(centers,X,dist_fun).^2;
    %     ratios = zeros(1,k);
    
    for i = 1:N
        for j = 1:k
            ratios = D(:,i)/D(j,i);
            ratios = 1./ratios;
            U(j,i) = 1/sum(ratios.^(2/(m-1)));
        end
    end
    
    obj_func(iter) = get_obj_fun(U,D);
    % Check for tolerance
    if iter > 1 && abs(obj_func(iter)-obj_func(iter-1))< tol
        obj_func(iter+1:end) = [];
        break
    end
    
end
end

function J = get_obj_fun(U,D)
J = U.*D;
J = sum(J(:));

end
