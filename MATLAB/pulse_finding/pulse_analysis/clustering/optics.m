function [reach_dist,core_dist,order] = optics(D,min_pts)
% OPTICS algorithm to cluster data
%
% SYNOPSIS: [reach_dist,core_dist,order] = optics(D,min_pts);
% INPUT: D - pairwise distance matrix
% x - data set (m,n); m-objects, n-variables
% k - number of objects in a neighborhood of the selected object
% (minimal number of objects considered as a cluster)
% -------------------------------------------------------------------------
% Output: 
% RD - vector with reachability distances (m,1)
% CD - vector with core distances (m,1)
% order - vector specifying the order of objects (1,m)
% -------------------------------------------------------------------------
% Example of use:
% x=[randn(30,2)*.4;randn(40,2)*.5+ones(40,1)*[4 4]];
% [RD,CD,order]=optics(x,4)
% -------------------------------------------------------------------------
% References: 
% [1] --------------------------
% Input: 
% x - data set (m,n); m-objects, n-variables
% k - number of objects in a neighborhood of the selected object
% (minimal number of objects considered as a cluster)
% -------------------------------------------------------------------------
% Output: 
% RD - vector with reachabilitity 
% with OPTICS, J. Chem. Inf. Comput. Sci. 42 (2002) 500-507
% -------------------------------------------------------------------------
% Written by Michal Daszykowski
% Department of Chemometrics, Institute of Chemistry, 
% The University of Silesia
% December 2004
% http://www.chemometria.us.edu.pl
% Updated Nov 2012, xies @mit.edu

% Initialize variables
N = size(D,1);
reach_dist = inf(1,N);

% Get the core distances between objects (convension: the first dimension
% in D is the reference object)
sorted_dist = sort(D,2);
core_dist = sorted_dist(:,min_pts + 1);

order = [];
seeds = 1:N;
idx = 1;

while ~isempty(seeds)
   
    this_obj = seeds(idx); % Grab a seed
    seeds(idx) = [];
    
    order = [order this_obj];
    
    maxm = max([ones(1,length(seeds))*core_dist(this_obj) ; D(this_obj,seeds)]);
    
    hyper_idx = (reach_dist(seeds)) > maxm;
    
    reach_dist(seeds(hyper_idx)) = maxm(hyper_idx);
    [~,idx] = min(reach_dist(seeds));
    
end

reach_dist(1) = max(reach_dist(2:N)) + 0.1*max(reach_dist(2:N));

end

% 
% function [D]=dist(i,x)
% 
% % function: [D]=dist(i,x)
% %
% % Aim: 
% % Calculates the Euclidean distances between the i-th object and all objects in x	 
% % Input: 
% % i - an object (1,n)
% % x - data matrix (m,n); m-objects, n-variables	    
% %                                                                 
% % Output: 
% % D - Euclidean distance (m,1)
% 
% [m,n]=size(x);
% D=(sum((((ones(m,1)*i)-x).^2)'));
% 
% if n==1
%    D=abs((ones(m,1)*i-x))';
% end
