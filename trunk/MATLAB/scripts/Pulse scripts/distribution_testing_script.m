%% Scripts to test some statistical properties of empirical v. simulated stiributions

MC = MC_wt_pcenter;
RC_num_near = cat(3,MC.random_cell.num_near);

bins = 0:20;

for label = 1:3

idx = [MC.empirical.origin_labels] == label;
subplot(1,3,label);
window = 6;

%%

display('---------------------')

X1 = squeeze(MC.empirical.num_near(idx,window));
X2 = squeeze(RC_num_near(idx,window,:));

[~,p] = kstest2(flat(X1),flat(X2),.05);
display(['Two-sample two-sided KS test: p = ' num2str(p)])

[~,p] = kstest2(flat(X1),flat(X2),.05,'smaller');
display(['Two-sample right-sided KS test: p = ' num2str(p)])

[~,p] = ttest2(flat(X1),flat(X2),.05);
display(['Two-sample two-sided T-test: p = ' num2str(p)])

[~,p] = ttest2(flat(X1),flat(X2),.05,'r');
display(['Two-sample right-sided T-test: p = ' num2str(p)])

m = mean(X2,1);
z = (mean(X1) - mean(m)) / std(m);
p = normcdf(-abs(z),0,1);

display(['Z score of means: z = ' num2str(z)])
display(['Z score of means: p = ' num2str(p)])

%%

KL = zeros(1,numel(MC.random_cell));

X1 = hist(MC.empirical.num_near(idx,window),bins);
X1 = X1 + eps;

for i = 1:numel(MC.random_cell)
    
    X2 = hist(MC.random_cell(i).num_near(idx,window),bins);
    X2 = X2 + eps;
    KL(i) = sqrt(kldiv(bins,X1/sum(X1),X2/sum(X2),'js'));
    
end

KL_perm = nan(numel(MC.random_cell));
for i = 1:numel(MC.random_cell)
    
    X1 = hist(MC.random_cell(i).num_near(idx,window),bins);
    X1 = X1 + eps;
    
    for j = 1:numel(MC.random_cell)
        
        if i > j
            
            X2 = hist(MC.random_cell(j).num_near(idx,window),bins);
            X2 = X2 + eps;
            KL_perm(i,j) = sqrt(kldiv(bins,X1/sum(X1),X2/sum(X2),'js'));
            
        end
    end
    
end

plot_pdf(flat(KL_perm),'FaceColor','red');
hold on
plot_pdf(flat(KL));
% xlabel('Sqrt of Jensen-Shannon divergence')
% ylabel('Probability')
% legend('Intra-permutation','Empirical - permutation');
title(behaviors{label});

end
%%
