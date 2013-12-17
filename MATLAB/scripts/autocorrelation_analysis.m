%% Auto-correlation analysis

wt = 20;

%%
% m_ac - myosin autocorrelation
% mr_ac - myosin rate autocorrelation

for i = 1:num_embryos

    m_ac{i} = nanxcorr(myosins_sm,myosins_sm,wt);
    m_ac{i} = m_ac{i}(:,wt+1:end);
    mr_ac{i} = nanxcorr(myosins_rate,myosins_rate,wt);
    mr_ac{i} = mr_ac{i}(:,wt+1:end);
    mr_ac{i} = delete_nan_rows(mr_ac{i},1);

    % a_ac = area autocorrelation
    % ar_ac = area rate autocorrelation

    a_ac{i} = nanxcorr(areas_sm,areas_sm,wt);
    a_ac{i} = a_ac{i}(:,wt+1:end);
    ar_ac{i} = nanxcorr(areas_rate,areas_rate,wt);
    ar_ac{i} = ar_ac{i}(:,wt+1:end);
    ar_ac{i} = delete_nan_rows(ar_ac{i},1);
    
end

%% Plot autocorrelations

C = jet(num_embryos);

for i = 1:num_embryos
    
    x = (0:wt)'*in(i).dt;
    
    figure(1)
    plot( ...
        x,nanmedian(mr_ac{i}),'color',C(i,:));
    title('Myosin rate autocorrelation')
    hold on
    
    figure(2)
    plot( ...
        x,nanmedian(ar_ac{i}),'color',C(i,:));
    title('Area rate autocorrelation')
    hold on
end
