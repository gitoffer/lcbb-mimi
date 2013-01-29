function [R2, res, templates] = get_cluster_residuals(data,cluster_labels,varargin)
%GET_CLUSTER_REDISUALS Calculates the R2 and residuals for how well the
% members of all clusters fit the "template", The default template is the
% median of the cluster.
% 
% USAGE: [R2,res,templates] = get_cluster_residuals(data,cluster_labels);
%        [R2,res,templates] = get_cluster_residuals(data,cluster_labels,@nanmean);
% INPUT: data

[N,p] = size(data);
num_cluster = max(cluster_labels);
% [num_clusters,~] = get_cluster_numbers(cluster_labels);
res = zeros(size(data));
R2 = zeros(1,N);

if nargin > 2
    fun = varargin{1};
else
    fun = @nanmedian;
end

%build templates
templates = zeros(num_cluster,p);
for i = 1:num_cluster
    this_cluster_data = data(cluster_labels == i,:);
    templates(i,:) = feval(fun,this_cluster_data);
    residuals = bsxfun(@minus,this_cluster_data,templates(i,:));
    res(cluster_labels == i,:) = residuals;
    R2(cluster_labels == i) = nansum(residuals.^2,2);
    
end


end


function [R2,res] = template_match(member,template)
%TEMPLATE_MATCH Calculates the R2 and residuals for how well a member of a
%cluster fits the 'template' of that cluster.
% 
% USAGE: [R2,res] = template_match(member, template)
%
% xies@mit.edu Jan 2013.

if any(size(member) ~= size(template))
    error('The input curve and the template should have the same dimensions!');
end

res = (member - template);
R2 = nansum(res.^2);

end
