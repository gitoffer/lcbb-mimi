function z_scores = zscore2d(matrix)

[~,num_obs] = size(matrix);

avg = nanmean(matrix,2);
stds = nanstd(matrix,1,2);

z_scores = (matrix-avg(:,ones(1,num_obs)))./stds(:,ones(1,num_obs));
