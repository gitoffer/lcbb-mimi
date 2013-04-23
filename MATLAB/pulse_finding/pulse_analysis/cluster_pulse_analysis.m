
IDs = kmeans_c5_pearson(:,1);
labels = kmeans_c5_pearson(:,2) + 1;

%%

% pulseOI = pulse(1:wt_cutoff);

for i = 1:5
    eval(['cluster' num2str(i) ' = fits_wt.get_fitID(IDs(labels == ' num2str(i) '));']);
end
