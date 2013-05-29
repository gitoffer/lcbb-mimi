
%% Make independent likelihood-ratios for different genotypes?
% lut - look-up table for likelihood ratio...use findnearest to look up
%
% use bins to control data binning

nbins = 201;
bins = linspace(-15,15,201);

%% Wild-type area rates

lut_wt = estimate_likelihood_ratio( ...
    areas_rate_cellularizing, areas_rate(:,[IDs.which] < 6), bins);
lut_wt_sm = smooth(lut_wt);

%% twist

lut_twist = estimate_likelihood_ratio( ...
    areas_rate_cellularizing, areas_rate(:,ismember([IDs.which], [6,7]) ), bins);
lut_twist_sm = smooth(lut_twist);

%% cta

lut_cta = estimate_likelihood_ratio( ...
    areas_rate_cellularizing, areas_rate(:,[IDs.which] > 7), bins);
lut_cta_sm = smooth(lut_cta);

%%

likelihood_ratio = nan(size(corrected_area_rate));

for j = 1:size(corrected_area_rate,2)
    for i = 1:size(corrected_area_rate,1)
        
        datum = corrected_area_rate(i,j);
        if ~isnan(datum)
            % Find which genotype -- via histc and generate LUT separately
            switch find( histc([IDs(fits_all(i).cellID).which],[0,1,6,8,11]) )
                case 2
                    value = lut_wt_sm(findnearest(datum , bins));
                case 3
                    value = lut_twist_sm(findnearest(datum , bins));
                case 5
                    value = lut_cta_sm(findnearest(datum , bins));
                otherwise
                    error('EmbryoID not found');
            end
        end
        
        if ~isnan(value) && ~isinf(value)
            likelihood_ratio(i,j) = value;
        end
        
    end
end

%%

fits_significant = fits(nanmean(likelihood_ratio,2) > 2);
fits_not_significant = fits(nanmean(likelihood_ratio,2) <= 2);

fits_sig_wt = fits_significant([fits_significant.embryoID] < 6);
fits_sig_twist = fits_significant(ismember([fits_significant.embryoID],[6,7]));
fits_sig_cta = fits_significant([fits_significant.embryoID] > 7);

fits_not_sig_wt = fits_not_significant([fits_not_significant.embryoID] < 6);
fits_not_sig_twist = fits_not_significant(ismember([fits_not_significant.embryoID],[6,7]));
fits_not_sig_cta = fits_not_significant([fits_not_significant.embryoID] > 7);

%% CTA cell-clustering

[N_sig,~] = hist( ...
    cat(1,c8( [fits_significant([fits_significant.embryoID] == 8).cellID] ) ...
    ),1:2);
[N_not_sig,bins] = hist( ...
    cat(1,c8( [fits_not_significant([fits_not_significant.embryoID] == 8).cellID] ) ...
    ),1:2);

bar(1:2,cat(1,N_sig,N_not_sig)','grouped');
legend('Significant (likelihood-ratio > 2)','Not significant');
set(gca,'XTickLabel',{'Constricting cells','Expanding cells'});
ylabel('Number of pulses');

