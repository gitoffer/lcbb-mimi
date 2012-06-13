%CLUSTER_DATA_SCRIPT Script to interface with MATLAB Bioinformatics Toolbox
% CLUSTERGRAM function.

data2cluster = mr_ac; 
secondaryData = ar_ac;

%% Get rid of unwanted rows
[data2cluster,ind] = delete_nan_rows(data2cluster,1);
deletedInd = setdiff(1:num_cells,foo);
data2cluster(:,deletedInd) = [];
secondaryData(:,deletedInd) = [];

%% Cluster via hierarchical
cg = clustergram(data,'ImputeFun',@knnimpute,'linkage','average', ...
    'Cluster',1,'RowPDist','euclidean','Colormap',redbluecmap, ...
    'Dendrogram',5);

%% 

foo = cg.RowLabels;
for i = 1:numel(foo)
    ind(i) = str2num(foo{i});
end

% Plot clustered data

figure,pcolor(data2cluster(ind,:)),colorbar
figure,pcolor(secondaryData(ind,:)),colorbar
figure,errorbar(nanmean(data2cluster),nanstd(data2cluster))
figure,errorbar(nanmean(secondaryData),nanstd(secondaryData)
