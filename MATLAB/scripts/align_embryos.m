% align_embryos

%% Fit Piecewise Continuous constant-linear model

split_img_frame = zeros(num_embryos,2); % raw image index
split_dev_frame = zeros(num_embryos,2); % EDGE index

for embryoID = 11:12

    % Fit PCCL
    [split_dev_frame(embryoID,:),split_img_frame(embryoID,:),xdata,models,p] = ...
        fit_PCCL(embryo_stack(embryoID),{'area','myosin_intensity'});
    
    figure % Plots both area, myosin, as well as respective PCCL models
    ax = plotyy( ...
        dev_time(embryoID,:),...
        nanmean(embryo_stack(embryoID).area,2), ...
        dev_time(embryoID,:),...
        nanmean(embryo_stack(embryoID).myosin_intensity,2) ...
        );
    % hold both axes
    set(ax,'NextPlot','add')
    plot( ax(1), xdata, models(:,1),'m-');
    plot( ax(2), xdata, models(:,2),'r-');
    xlabel('Developmental time (sec)')
    ylabel('Average apical area (\mum^2)');
    ylabel(ax(2),'Myosin intensity');
    
    vline( dev_time(embryoID,split_dev_frame(embryoID,1)) + 1,'m--');
    vline( dev_time(embryoID,split_dev_frame(embryoID,2)) + 1,'r--');
    title(['Embryo #' num2str( embryoID )]);
    drawnow
    hold off
    
    display(['Slope = ' num2str(p(2)) ' (um^2/sec)']);
    
end

%% Visualizing mean properties

name2plot = 'area_sm';

figure, clear H
embryoID_OI = [1:5];
color = hsv(numel(embryoID_OI));
for i = 1:numel( embryoID_OI )
    
%     switch i
%         case 1
%             label = c8;
%         case 2
%             label = c9;
%         case 3
%             label = c10;
%     end
    
    embryoID = embryoID_OI(i);
    
    time = embryo_stack(embryoID).dev_time;
    data = embryo_stack(embryoID).(name2plot);
    
%     data = bsxfun(@rdivide,data,nanmean(data));
    
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
ylabel('Number of cells connected by myosin')
xlabel('Developmental time')
legend([H.mainLine],entries)
