%% Nearby pulse analysis

%%

time_windows = 10:10:100; %seconds

fits = fits.find_near_fits(time_windows,neighborID);

%%

nearIDs = cat(1,fits.nearIDs);

% Convert to number of pulses
num_near = cellfun(@(x) numel(x(~isnan(x))), nearIDs);

%%

wt_num_near = num_near( [fits.embryoID] < 6,:);

twist_num_near = num_near( ismember([fits.embryoID], 6:7),:);

cta_num_near = num_near( [fits.embryoID] > 7,:);

%%

clear H
H(1) = shadedErrorBar( time_windows, mean(wt_num_near), std(wt_num_near), 'k-', 1);
hold on
H(2) = shadedErrorBar( time_windows, mean(twist_num_near), std(twist_num_near), 'b-', 1);
H(3) = shadedErrorBar( time_windows, mean(cta_num_near), std(cta_num_near), 'r-', 1);
legend([H.mainLine],'WT','twist','cta')

%%

entries = {'Ratcheted (stereotyped)','Ratcheted (weak)','Ratcheted (delayed)','Un-ratcheted','Stretched'};
N = zeros(num_clusters);
num_member = zeros(1,num_clusters);

for i = 1:num_clusters
   
   foo = nearIDs( [fits.cluster_label] == order(i) & [fits.embryoID] < 6,:);   
   N(i,:) = hist(revorder([fits_wt.get_fitID([foo{:,3}]).cluster_label]),1:num_clusters);
   num_member(i) = numel( fits_wt( [fits_wt.cluster_label] == order(i) ));

end

num_neighbors = sum(N,1);

subplot(2,1,1)
bar(1:5,cat(1,num_member,num_neighbors)');
ylabel('Count');
legend('Numbero of pulses','Number of neighbors');
set(gca,'XTickLabel',entries);

subplot(2,1,2)
bar(1:5,bsxfun(@rdivide,N,sum(N,1))');
legend(entries{:});
set(gca,'XTickLabel',entries);
ylabel('Neighbor probability');
xlabel('Center cluster labels');
