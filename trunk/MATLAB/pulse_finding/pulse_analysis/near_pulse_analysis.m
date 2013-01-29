wt_cutoff = find([pulse.embryo]<6,1,'last');
% pulseOI = pulse([pulse.pulseID] < wt_cutoff);
num_peaks = numel(pulse);

time_windows = 5:5:30; %seconds
near_pulses = cell(6,num_peaks);
nearID = cell(6,num_peaks);
num_near = zeros(6,num_peaks);

for j = 1:6
    time_window = time_windows(j);
    for i = 1:num_peaks
        [near_pulses{j,i},nearID{j,i}] = ...
            find_near_pulses(pulse,i,time_window,neighborID,master_time);
        %     near_pulses{i} = near;
        num_near(j,i) = numel(near_pulses{j,i});
    end
    
end

%%
foo = 1:8

cluster_pulse_density(1,:) = nanmean(num_near(:, ...
    [pulseOI([pulseOI.cluster_label]==foo(1)).pulseID]),2);
cluster_pulse_density(2,:) = nanmean(num_near(:,...
    [pulseOI([pulseOI.cluster_label]==foo(2)).pulseID]),2);
cluster_pulse_density(3,:) = nanmean(num_near(:,...
    [pulseOI([pulseOI.cluster_label]==foo(3)).pulseID]),2);
cluster_pulse_density(4,:) = nanmean(num_near(:,...
    [pulseOI([pulseOI.cluster_label]==foo(4)).pulseID]),2);
cluster_pulse_density(5,:) = nanmean(num_near(:,...
    [pulseOI([pulseOI.cluster_label]==foo(5)).pulseID]),2);

cluster_std(1,:) = nanstd(num_near(:, ...
    [pulse([pulse.cluster_label]==foo(1)).pulseID]),[],2);
cluster_std(2,:) = nanstd(num_near(:,...
    [pulse([pulse.cluster_label]==foo(2)).pulseID]),[],2);
cluster_std(3,:) = nanstd(num_near(:,...
    [pulse([pulse.cluster_label]==foo(3)).pulseID]),[],2);
cluster_std(4,:) = nanstd(num_near(:,...
    [pulse([pulse.cluster_label]==foo(4)).pulseID]),[],2);
cluster_std(5,:) = nanstd(num_near(:,...
    [pulse([pulse.cluster_label]==foo(5)).pulseID]),[],2);

figure
errorbar(time_windows,cluster_pulse_density(1,:),cluster_std(1,:))
hold on
errorbar(time_windows,cluster_pulse_density(2,:),cluster_std(2,:),'r')
errorbar(time_windows,cluster_pulse_density(3,:),cluster_std(3,:),'g')
errorbar(time_windows,cluster_pulse_density(4,:),cluster_std(4,:),'c')
errorbar(time_windows,cluster_pulse_density(5,:),cluster_std(5,:),'k')
hold on
% errorbar(time_windows,nanmean(num_near(:,[pulse.embryo]<6),2),...
%     nanstd(num_near(:,[pulse.embryo]<6),[],2),'LineWidth',5,'Color','y');
% errorbar(time_windows,nanmean(num_near(:,[pulse.embryo]>5),2),...
%     nanstd(num_near(:,[pulse.embryo]>5),[],2),'LineWidth',5,'Color','r');
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5');
% plot(cluster_pulse_density')

