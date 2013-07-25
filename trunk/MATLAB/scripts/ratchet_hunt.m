ratcheted = [cluster1_wt cluster2_wt cluster3_wt];
unratcheted = cluster4_wt;

N = 2; colors = {'b','r'};

% measurements to plot (up to four)
measurements = {myosin_ring1+myosin_ring2,myosin_inside,myosin_fraction,myosin_connection};
names = {'Junctional myosin','Medial myosin','Fraction of cell occupied by myosin','# cells connected'};
ytitles = {'Intensity (a.u.)','Intensity (a.u.)','Fraction','Number of cells'};
ylimits = {[0 1.5e4],[0 .8e4],[0 1],[0 90]};
which = 1;
% rearrange order so that [which] comes first
measurements = [measurements(which) measurements(setdiff(1:4,which))];
names = [names(which) names(setdiff(1:4,which))];
ytitles = [ytitles(which) ytitles(setdiff(1:4,which))];
ylimits = [ylimits(which) ylimits(setdiff(1:4,which))];

% construct anon function for filtering pulses
condition = @(x) ([x.center] > 0 & [x.center] < 60);

%% bootstrap ratcheted
figure

% gather data
toplot = ratcheted( condition( ratcheted )).sort('cluster_weight');
x = fits(1).corrected_time;
Nsample = 100;

% bootstrap using unratcheted bins
bootstats = zeros(4, Nsample, numel(x));
for N = 1:Nsample
    
    distr = hist([unratcheted( condition( unratcheted )).bin],1:4);
    idx = dist_sampler([toplot.bin],distr,1:4);
    sampled = toplot(idx).sort('cluster_weight');
    weights = cat(1,sampled.cluster_weight);
    
    % Gather sampled data
    for i = 1:4
        % collect
        bootstats(i,N,:) = nanwmean( ...
            get_corrected_pulse_measurement(sampled,measurements{i},input,fit_opts), ...
            weights);
    end
    
end

% pseudo-color is special
subplot(4,2,[1 3]);
imagesc(x,1:numel(toplot), cat(1,toplot.corrected_area_norm)); colorbar
title(['BS average: ' names{1}]);

for i = 1:4
    
    subplot(4,2, 4+i);
    
    M = squeeze( bootstats(i,:,:) );
    plot( x, M, colors{1});
    hold on
    title(['BS: ' names{i}]);
    xlabel('Pulse time (sec)');set(gca,'XLim',[-50 60]);
    ylabel(ytitles{i});set(gca,'YLim',ylimits{i});
    
end

%% plot unratcheted portion

% gather data
toplot = unratcheted(condition( unratcheted )).sort('cluster_weight');
x = fits(1).corrected_time;
weights = cat(1,toplot.cluster_weight);

% pseudo-color is special
M = get_corrected_pulse_measurement(toplot,measurements{1},input,fit_opts);
subplot(4,2,[2 4]);
imagesc(x,1:numel(toplot), cat(1,toplot.corrected_area_norm)); colorbar
title(names{1});

for i = 1:4
    
    h(i) = subplot(4,2, 4+i);
    hold on
    M = get_corrected_pulse_measurement(toplot,measurements{i},input,fit_opts);
	shadedErrorBar(x, nanwmean(M,weights),nanstd(M),colors{2},1);
%     for j = 1:size(M,1) % workaround to get transparent lines
%         y = M(j,:);
%         xflip = [x(1 : end - 1) fliplr(x)];
%         yflip = [y(1 : end - 1) fliplr(y)];
%         patch(xflip, yflip, 'r', 'EdgeColor', colors{2}, 'LineWidth', 5, 'EdgeAlpha', 0.1, 'Facealpha', 0);
%         hold on
%     end
    title(names{i});
    xlabel('Pulse time (sec)');set(gca,'XLim',[-50 60]);
    ylabel(ytitles{i});set(gca,'YLim',ylimits{i});
end

linkaxes(h,'x');


%% plot ratcheted portion

% gather data
toplot = ratcheted(condition( ratcheted )).sort('cluster_weight');
x = fits(1).corrected_time;
weights = cat(1,toplot.cluster_weight);

% pseudo-color is special
M = get_corrected_pulse_measurement(toplot,measurements{1},input,fit_opts);
subplot(4,2,[1 3]);
imagesc(x,1:numel(toplot), cat(1,toplot.corrected_area_norm)); colorbar
title(names{1});

for i = 1:4
    
    h(i) = subplot(4,2, 4+i);
    hold on
    M = get_corrected_pulse_measurement(toplot,measurements{i},input,fit_opts);
	shadedErrorBar(x, nanwmean(M,weights),nanstd(M),colors{1},1);
%     for j = 1:size(M,1) % workaround to get transparent lines
%         y = M(j,:);
%         xflip = [x(1 : end - 1) fliplr(x)];
%         yflip = [y(1 : end - 1) fliplr(y)];
%         patch(xflip, yflip, 'b', 'EdgeColor', colors{2}, 'LineWidth', 5, 'EdgeAlpha', 0.1, 'Facealpha', 0);
%         hold on
%     end
    title(names{i});
    xlabel('Pulse time (sec)');set(gca,'XLim',[-50 60]);
    ylabel(ytitles{i});set(gca,'YLim',ylimits{i});
end

linkaxes(h,'x');