ratcheted = fitsOI.get_cluster([1]);
unratcheted = fitsOI.get_cluster(4);

N = 2; colors = {'b','r'};

% measurements to plot (up to four)
measurements = {myosin_fraction,myosins,myosin_inside+myosin_ring3,myosin_ring1+myosin_ring2};
names = {'Total myosin','area','Medial myosin','Junctional myosin'};
ytitles = {'Intensity (a.u.)','a.u.','a.u.','\mum^2'};
ylimits = {[0 1],[0 1],[0 1],[0 1]};
which = 4;

% rearrange order so that [which] comes first
measurements = [measurements(which) measurements(setdiff(1:4,which))];
names = [names(which) names(setdiff(1:4,which))];
ytitles = [ytitles(which) ytitles(setdiff(1:4,which))];
ylimits = [ylimits(which) ylimits(setdiff(1:4,which))];

for i = [1 3 4]
    m = measurements{i};
    for j = 1:11
        thism = m(:,[IDs.which]== j);
        thism = thism/max(thism(:));
        m(:,[IDs.which]==j) = thism;
    end
    measurements{i} = m;
end

% construct anon function for filtering pulses
condition = @(x) ([x.center] < Inf);

%% bootstrap ratcheted
% figure

% gather data
toplot = ratcheted( condition( ratcheted )).sort('cluster_weight');
x = fits(1).corrected_time;
Nsample = 100;

% bootstrap using unratcheted bins
bootstats = zeros(10, Nsample, numel(x));
for N = 1:Nsample
    
    N_amp_bins = max( unique([ fits.bin ]) );
    
    distr = hist([unratcheted( condition( unratcheted )).bin], 1:N_amp_bins);
    idx = dist_sampler([toplot.bin],distr, 1:N_amp_bins);
    sampled = toplot(idx).sort('cluster_weight');
    weights = cat(1,sampled.cluster_weight);
    
    % Gather sampled data
    for i = 1:4
        % collect
        bootstats(i,N,:) = nanwmean( ...
            sampled.get_corrected_measurement(measurements{i},input), ...
            weights);
    end
    
end

% pseudo-color is special
subplot(4,2,[1 3]);
imagesc(x,1:numel(toplot), squeeze(bootstats(1,:,:)) ); colorbar
title(['BS average: ' names{1}]);

for i = 1:4
    
    subplot(4,2, 4+i);
    
    M = squeeze( bootstats(i,:,:) );
    plot(x,nanmean(M),'k');
    hold on
    
end

%% plot unratcheted portion

% gather data
toplot = unratcheted(condition( unratcheted )).sort('amplitude');
x = fits(1).corrected_time;
% weights = cat(1,toplot.cluster_weight);

% pseudo-color is special
M = toplot.get_corrected_measurement(cells,measurements{1},input);
subplot(4,2,[2 4]);
imagesc(x,1:numel(toplot), M); colorbar;
title(names{1});

for i = [1 3 4]
    
    h(i) = subplot(4,2, 4+i);
    hold on
    M = get_corrected_measurement(toplot,cells,measurements{i},input);
	shadedErrorBar(x, nanmean(M),nanstd(M), ...
    colors{2},1);
%     for j = 1:size(M,1) % workaround to get transparent lines
%         y = M(j,:);
%         xflip = [x(1 : end - 1) fliplr(x)];
%         yflip = [y(1 : end - 1) fliplr(y)];
%         patch(xflip, yflip, 'r', 'EdgeColor', colors{2}, 'LineWidth', 5, 'EdgeAlpha', 0.1, 'Facealpha', 0);
%         hold on
%     end
    xlim([-80 80]);
    title(names{i});
    xlabel('Pulse time (sec)');set(gca,'XLim',[-50 60]);
    ylabel(ytitles{i});set(gca,'YLim',ylimits{i});
end

% linkaxes(h,'x');

%% plot ratcheted portion

% gather data
toplot = ratcheted(condition( ratcheted )).sort('amplitude');
x = fits(1).corrected_time;
% weights = cat(1,toplot.cluster_weight);

% pseudo-color is special
M = toplot.get_corrected_measurement(cells,measurements{1},input);
subplot(4,2,[1 3]);
imagesc(x,1:numel(toplot), M); colorbar
title(names{1});

for i = [1 3 4]
    
    h(i) = subplot(4,2, 4+i);
    hold on
    M = get_corrected_measurement(toplot,cells,measurements{i},input);
	shadedErrorBar(x, nanmean(M),nanstd(M),...
    colors{1},1);

    title(names{i});
    xlim([-80 80]);
    xlabel('Pulse time (sec)');set(gca,'XLim',[-50 60]);
    ylabel(ytitles{i});set(gca,'YLim',ylimits{i});
end

% linkaxes(h,'x');


%% boxplot
ratID = [fits.embryoID] > 5 & [fits.cluster_label] < 4;
unratID = [fits.embryoID] > 5 & [fits.cluster_label] == 4;

subplot(4,2,6);
hold on
[X,G] = make_boxplot_args(num_near(ratID,6),num_near(unratID,6),{'Ratcheted','Unratcheted'});
boxplot(X,G)