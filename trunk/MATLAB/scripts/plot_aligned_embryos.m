%align_embryos

num_embryos = numel(input) - 2;
name2plot = 'myosin_sm';

figure
color = hsv(num_embryos);
embryoID_OI = [8:10];
for i = 1:numel( embryoID_OI )
    
    switch i
        case 1
            label = c;
        case 2
            label = c9;
        case 3
            label = c10;
    end
    
    embryoID = embryoID_OI(i);
    
    time = embryo_stack(embryoID).dev_time;
    
    data = embryo_stack(embryoID).(name2plot);
    data = data(:,label == 1);
    
    H(i) = shadedErrorBar(time, ...
        nanmean(data,2), nanstd(data,[],2), ...
        {'color',color(i,:)},1);
    
    entries{i} = ['Embryo ' num2str(embryoID) ', ' num2str(input(embryoID).dt) ' sec/frame'];
    
    hold on
    
end

hold off
xlabel('Time (sec)')
legend([H.mainLine],entries)
