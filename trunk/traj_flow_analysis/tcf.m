options = struct('time_avg','off','local','on','mean_subt','on');

dT = 16;
Tmax = max(numel(stics_img));

[Ct,T] = get_tcf4stics(stics_img,dT,Tmax,stics_opt,options);
h = plot(T,Ct);
xlabel('Time (min)')
ylabel('Temporal correlation')
mkdir([io.save_name '/TCF/']);
title('C(\tau)')
saveas(h,[io.save_name '/TCF/temporal_coherence_'],'fig')
