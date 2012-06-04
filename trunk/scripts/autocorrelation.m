%% auto-correlation analysis

wt = 15;

%%
% m_ac = nanxcorr(myosins_sm,myosins_sm,wt);
% m_ac = m_ac(:,wt+1:end);
% mr_ac = nanxcorr(myosins_rate,myosins_rate,wt);
% mr_ac = mr_ac(:,wt+1:end);
% mr_ac = delete_nan_rows(mr_ac,1);

a_ac = nanxcorr(areas_sm,areas_sm,wt);
a_ac = a_ac(:,wt+1:end);
ar_ac = nanxcorr(areas_rate,areas_rate,wt);
ar_ac = ar_ac(:,wt+1:end);
% ar_ac = delete_nan_rows(ar_ac,1);

% figure,pcolor(m_ac),colorbar
% figure,pcolor(mr_ac),colorbar
figure,pcolor(a_ac),colorbar
figure,pcolor(ar_ac),colorbar

% figure,errorbar(nanmedian(mr_ac),nanstd(mr_ac));title('Myosin rate autocorrelation')
figure,errorbar(nanmedian(ar_ac),nanstd(ar_ac));title('Area rate autocorrelation')

% mr_ac_rect = mr_ac; mr_ac_rect(mr_ac_rect < 0) = 0;
% [mr_ac_rect,foo] = delete_nan_rows(mr_ac_rect,1);
% deletedInd = setdiff(1:num_cells,foo);

%%
cg = clustergram(mr_ac_rect,'ImputeFun',@knnimpute,'Linkage','complete', ...
    'Cluster',1,'RowPDist','euclidean','Colormap',redbluecmap, ...
    'Dendrogram',5);

%%
mr_ac(deltedInd,:) = [];
ar_ac(deltedInd,:) = [];

%%
foo = cg.RowLabels;
for i = 1:numel(foo)
    ind(i) = str2num(foo{i});
end

%%
% toplot = ind;
% toplot = setdiff(ind,nonInd);
figure,pcolor(mr_ac(ind,:)),colorbar
figure,pcolor(ar_ac(ind,:)),colorbar
figure,errorbar(nanmean(mr_ac),nanstd(mr_ac))
figure,errorbar(nanmean(ar_ac),nanstd(ar_ac))