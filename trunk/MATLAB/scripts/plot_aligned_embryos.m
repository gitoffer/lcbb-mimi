%align_embryos

num_embryos = numel(input);
name2plot = 'area';

figure
color = hsv(num_embryos);
for i = 1:num_embryos
    
    time = embryo_stack(i).dev_time;
    
    H(i) = shadedErrorBar(time, ...
        nanmean(embryo_stack(i).(name2plot),2), ...
        nanstd(embryo_stack(i).(name2plot),[],2),{'color',color(i,:)},1);
    
    entries{i} = ['Embryo ' num2str(i) ', ' num2str(input(i).dt) ' sec/frame'];
    
    hold on
    
end
hold off
xlabel('Time (sec)')
legend([H.mainLine],entries)
