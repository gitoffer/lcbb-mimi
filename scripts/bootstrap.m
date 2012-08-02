T = 100;
bsa_means = zeros(1,T);
bsa_std = zeros(1,T);
random_acorr = zeros(num_cells,num_cells,T);

for i = 1:T
    random_areasrate = areas_rate(:,randperm(num_cells));
    acorr_random = squareform(pdist(random_areasrate(1:50,:)', @(x,y) nan_pearsoncorr(x,y)));
    acorr_random(logical(eye(num_cells))) = NaN;
    acorr_random = acorr_random.*adj;
    random_acorr(:,:,i) = acorr_random;
    bsa_means(i) = nanmean(acorr_random(:));
    bsa_std(i) = nanstd(acorr_random(:));
    
end

%%

wt = 10;
mean_correlations = nan(T,2*wt+1);
std_correlations = nan(T,2*wt+1);

for i = 1:T
    random_areasrate = areas_rate(:,randperm(num_cells));
    random_myosinsrate = myosins_rate(:,randperm(num_cells));
    
    correlations_random = ...
        nanxcorr(random_areasrate,random_myosinsrate,wt);
    mean_correlations(i,:) = nanmean(correlations_random);
    std_correlations(i,:) = nanstd(correlations_random);
end

%%

T = 100;
bsm_means = zeros(1,T);
bsm_std = zeros(1,T);
random_mcorr = zeros(num_cells,num_cells,T);

for i = 1:T
    random_myosinsrate = myosins_rate(:,randperm(num_cells));
    mcorr_random = squareform(pdist(random_myosinsrate(1:50,:)', @(x,y) nan_pearsoncorr(x,y)));
    mcorr_random(logical(eye(num_cells))) = NaN;
    mcorr_random = mcorr_random.*adj;
    random_mcorr(:,:,i) = mcorr_random;
    bsm_means(i) = nanmean(mcorr_random(:));
    bsm_std(i) = nanstd(mcorr_random(:));
    
end

%%

wt = 10;
mean_correlations = nan(T,2*wt+1);
std_correlations = nan(T,2*wt+1);

for i = 1:T
    random_areasrate = areas_rate(:,randperm(num_cells));
    random_myosinsrate = myosins_rate(:,randperm(num_cells));
    
    correlations_random = ...
        nanxcorr(random_areasrate,random_myosinsrate,wt);
    mean_correlations(i,:) = nanmean(correlations_random);
    std_correlations(i,:) = nanstd(correlations_random);
end