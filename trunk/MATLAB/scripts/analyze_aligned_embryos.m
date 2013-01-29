%% analyze_aligned_embryos.m

%% Plot the mean area of each embryo in aligned time

C = varycolor(num_embryos);

for i = 1:num_embryos-2
    handles(i) = shadedErrorBar([master_time(i).aligned_time], ...
        nanmean(areas_sm(:,[IDs.which]==i),2), ...
        nanstd(areas_sm(:,[IDs.which]==i),[],2),{'Color',C(i,:)},1);
    hold on;
end
xlabel('Aligned time (sec)')
ylabel('Apical area (um^2)')

%%
figure
for i = 1:num_embryos-2
    handles(i) = shadedErrorBar([master_time(i).aligned_time], ...
        nanmean(myosins_sm(:,[IDs.which]==i),2), ...
        nanstd(myosins_sm(:,[IDs.which]==i),[],2),{'Color',C(i,:)},1);
    hold on;
end
xlabel('Aligned time (sec)');
ylabel('Apical area (um^2)');

%%