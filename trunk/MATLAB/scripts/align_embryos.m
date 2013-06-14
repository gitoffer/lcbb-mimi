%align_embryos

num_embryos = numel(input);
name2plot = 'area_sm';

figure, clear H
embryoID_OI = [1:5];
color = hsv(numel(embryoID_OI));
for i = 1:numel( embryoID_OI )
    
    switch i
        case 1
            label = c8;
        case 2
            label = c9;
        case 3
            label = c10;
    end
    
    embryoID = embryoID_OI(i);

    time = embryo_stack(embryoID).dev_time;
    data = embryo_stack(embryoID).(name2plot);
    
    switch i
        case 1
            data(55:60,:) = NaN;
        case 2
            data(60:70,:) = NaN;
        case 4
            data(70:75,:) = NaN;
        case 5
            data(125:130,:) = NaN;
            time = time + 60;
    end
    
    H(i) = shadedErrorBar(time,...
        nanmean(data,2), nanstd(data,[],2), ...
        {'color',color(i,:)},1);
    
    entries{i} = ['Embryo ' num2str(embryoID) ', ' num2str(input(embryoID).dt) ' sec/frame'];
    
    hold on
    
end

hold off
ylabel('Average tissue area (\mum^2)')
xlabel('Developmental time')
% legend([H.mainLine],entries)
