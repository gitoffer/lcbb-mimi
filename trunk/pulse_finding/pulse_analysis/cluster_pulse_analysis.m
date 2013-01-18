wt_cutoff = find([sub_pulse.embryo]<6,1,'last');

% pulseOI = pulse(1:wt_cutoff);
clusterID1 = kmeansID_filt(kmeans_filt_labels==1);
clusterID2 = kmeansID_filt(kmeans_filt_labels==2);

binned1 = bin_pulses(pulse(clusterID1(clusterID1 < wt_cutoff)));
binned2 = bin_pulses(pulse(clusterID2(clusterID2 < wt_cutoff)));

binned1_topIDs = [binned1{1}.pulseID binned1{2}.pulseID];
binned2_topIDs = [binned2{1}.pulseID binned2{2}.pulseID];
