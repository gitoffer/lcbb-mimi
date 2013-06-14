% align_embryos

%% Fit Piecewise Continuous constant-linear model

ref_frames = zeros(1,num_embryos);
for embryoID = 1:10
    
    field2fit = 'area';
    
    frames = 1:input(embryoID).last_segmented - input(embryoID).t0;
    
    data2fit = nanmean( embryo_stack(embryoID).(field2fit), 2)';
    data2fit = data2fit( frames );
    
    xdata = dev_time( embryoID, frames );
    results = zeros(numel(xdata) - 2, numel(xdata) );
    resnorm = zeros(numel(xdata) - 2,1);
    
    for i = 1:numel(xdata) - 2
        split_time = i + 1;
        guess = [nanmean(data2fit), nanmax(data2fit) - nanmin(data2fit)];
        
        % Perform LSQ fitting
        opts = optimset('Display','off');
        [p,resnorm(i)] = lsqcurvefit( @(p,x) lsq_PCCL(p,x,split_time), ...
            guess,xdata,data2fit, ...
            [],[],opts);
        results(i,:) = lsq_PCCL(p,xdata,split_time);
        
    end
    
    figure
    ax = plotyy( xdata, data2fit, xdata(2:end-1), resnorm);
    xlabel('Developmental time (sec)')
    ylabel(ax(1),'Average apical area (\mum^2)');
    ylabel(ax(2),'Squared residuals');
    hold on
    [~,ref_frames(embryoID)] = min(resnorm);
    vline( xdata(ref_frames(embryoID)) + 1,'r--');
    title(['Embryo #' num2str( embryoID )]);
    drawnow
    hold off
end

%% Visualizing mean properties

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
