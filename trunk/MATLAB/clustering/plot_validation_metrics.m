function plot_validation_metrics(metrics)

names = fieldnames(metrics);
colorset = varycolor(numel(names));
for i = 1:numel(names);
    hold on
    eval(['plot([metrics.' names{i} '],''color'',colorset(i,:));']);
end
legend(names);

end
