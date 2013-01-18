function metrics = validate_cluster(clustering,varargin)
%VALIDATE_CLUSTER A wrapper a suite of validation metric of the wellness
% of cluster of an input DATA by CLUSTER. Contains NaN support.
%
% SNYNOPSIS: metrics =
% validate_cluster(data,cluster,'metric1','metric2',...)
%
% INPUT: DATA - data that was clustered
%        CLUSTER - clustering results with pairwise-distances used, the
%        method name, and the labels generated
%        STRINGS of metric names - will default to all the compatible
%                methods with the specified clustering technique
%
% Metrics currently implemented:
% (all)  'Dunn index', 'Silhouette'
% (dendrogram) 'Cophenetic'

% The data contains N points in p dimensions
% [N,p] = size(data);
% num_cluster = numel(unique(cluster.labels));

metric_names = varargin;
if isempty(metric_names)
    switch clustering.method
        case 'hierarchical'
            metric_names = {'Dunn index','silhouette','cophenetic'};
        case 'crisp'
            metric_names = {'Dunn index','silhouette'};
        case 'fuzzy'
        otherwise
    end
end
if isempty(varargin)
    varargin = {'Dunn index','silhouette'};
end
if any(strcmpi(metric_names,'Dunn index'))
    DI = dunn_index(clustering);
    metrics.dunn = DI;
end
% if any(strcmpi(metric_names,'Alternative Dunn index')
    
if any(strcmpi(metric_names,'Silhouette'))
    sil = silhouette_width(clustering);
    metrics.silhouette = sil;
end
if any(strcmpi(metric_names,'Connectivity')) 
    conn = connectivity_index(clustering);
    metrics.connectivity = conn;
end
if any(strcmpi(metric_names,'Cophenetic')) % Uses MATLAB built-in function
    [coph,~] = cophenet(clustering.dendrogram,clustering.labels);
    metrics.cophenetic = nanmean(coph);
end
if any(strcmpi(metric_names,''));
end


end