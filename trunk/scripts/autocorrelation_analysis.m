%% Auto-correlation analysis

wt = 20;

%%
% m_ac - myosin autocorrelation
% mr_ac - myosin rate autocorrelation

m_ac = nanxcorr(myosins_sm,myosins_sm,wt);
m_ac = m_ac(:,wt+1:end);
mr_ac = nanxcorr(myosins_rate,myosins_rate,wt);
mr_ac = mr_ac(:,wt+1:end);
mr_ac = delete_nan_rows(mr_ac,1);

% a_ac = area autocorrelation
% ar_ac = area rate autocorrelation

a_ac = nanxcorr(areas_sm,areas_sm,wt);
a_ac = a_ac(:,wt+1:end);
ar_ac = nanxcorr(areas_rate,areas_rate,wt);
ar_ac = ar_ac(:,wt+1:end);
ar_ac = delete_nan_rows(ar_ac,1);

%% Plot autocorrelations

figure,pcolor(m_ac),colorbar,title('Myosin autocorrelation')
figure,pcolor(mr_ac),colorbar,title('Myosin rate autocorrelation')
figure,pcolor(a_ac),colorbar,title('Area autocorrelation')
figure,pcolor(ar_ac),colorbar,title('Area rate autocorrelation')

figure,errorbar(nanmedian(mr_ac),nanstd(mr_ac));title('Myosin rate autocorrelation')
figure,errorbar(nanmedian(ar_ac),nanstd(ar_ac));title('Area rate autocorrelation')

