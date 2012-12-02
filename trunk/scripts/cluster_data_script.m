%CLUSTER_DATA_SCRIPT Script to interface with MATLAB Bioinformatics Toolbox
% CLUSTERGRAM function.

data = corrected_area_norm(:,:);
data2cluster = interp_mat(data);

%% Cluster via hierarchical
cg = clustergram(data2cluster,'ImputeFun',@knnimpute,'linkage','complete', ...
    'Cluster',1,'RowPDist',@nan_eucdist,'Colormap',jet, ...
    'Dendrogram',0);

%%

distances = pdist(data2cluster,@nan_pearsoncorr);
% distances = pdist(data2cluster,@nan_eucdist);
Z = linkage(distances,'complete');
figure,h = dendrogram(Z,0,'Orientation','left');

%%

labels = cluster(Z,'maxclust',9);
[X,Y] = meshgrid(dt,1:num_peaks);
x = dt;

%% Uses the cluster visualization GUI

visualize_cluster(data2cluster,Z,[-15 15])

%% Plot individual clusters

figure,
i = 7;
shadedErrorBar(x,nanmean(data2cluster(labels == i,:)),nanstd(data2cluster(labels == i,:)),'r-',1);
hold on
plot(x,data2cluster(labels == i,:));

foo = find(labels == i);
for i = 1:numel(foo)
    legend_labels{i} = ['Embryo ' num2str(sub_pulse(foo(i)).embryo) ...
        ', Cell ' num2str(sub_pulse(foo(i)).cellID) ...
        ', Frame ' num2str(fix(sub_pulse(foo(i)).center_frame))];
end
legend(legend_labels)

%%

figure
showsub_vert(...
    @pcolor,{X(1:numel(labels(labels==1)),:),Y(1:numel(labels(labels==1)),:),[pulse(labels==1).curve_padded]'},...
    '1','shading flat;colorbar;caxis([0 5e4]);',...
    @pcolor,{X(1:numel(labels(labels==2)),:),Y(1:numel(labels(labels==2)),:),[pulse(labels==2).curve_padded]'},...
    '2','shading flat;colorbar;caxis([0 5e4]);',...
    @pcolor,{X(1:numel(labels(labels==3)),:),Y(1:numel(labels(labels==3)),:),[pulse(labels==3).curve_padded]'},...
    '3','shading flat;colorbar;',...
    3);

% @pcolor,{data2cluster(labels==4,:)},'4','shading flat;caxis([-20 20]);colorbar',...
%     @errorbar,{-10:10,nanmean(data2cluster(labels==4,:)),nanstd(data2cluster(labels==4,:),[])},'','xlabel(''Aligned time'')',...
%     @pcolor,{data2cluster(labels==5,:)},'5','shading flat;caxis([-20 20]);colorbar',...
%     @errorbar,{-10:10,nanmean(data2cluster(labels==5,:)),nanstd(data2cluster(labels==5,:),[])},'','xlabel(''Aligned time'')',...
%     3);
