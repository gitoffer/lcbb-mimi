%align_embryos

num_embryos = numel(input) - 2;
name2plot = 'area_sm';

figure
color = hsv(num_embryos);
embryoID_OI = [8:9];
for i = 1:numel( embryoID_OI )
    
    embryoID = embryoID_OI(i);
    
    time = embryo_stack(embryoID).dev_time;
    
    H(i) = shadedErrorBar(time, ...
        nanmean(embryo_stack(embryoID).(name2plot),2), ...
        nanstd(embryo_stack(embryoID).(name2plot),[],2), ...
        {'color',color(i,:)},1);
    
    entries{i} = ['Embryo ' num2str(embryoID) ', ' num2str(input(embryoID).dt) ' sec/frame'];
    
    hold on
    
end

hold off
xlabel('Time (sec)')
legend([H.mainLine],entries)
