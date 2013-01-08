function plot_mds(Y,labels)

figure;
num_clusters = numel(unique(labels));
colorset = varycolor(num_clusters);

for i = 1:num_clusters
    hold on
    scatter3(Y(labels==i,1),Y(labels==i,2),Y(labels==i,3),...
        20,colorset(i,:));
end
hold off

end