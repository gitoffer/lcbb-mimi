% Pulse timing 

fitsOI = fits.get_embryoID(1:5);
bins = linspace(-300,400,50);
x_limits = [-300 400];

%% by bin

colors = pmkmp(10);

for i = 1:10
    hold on;
%     N = hist([fitsOI([fitsOI.bin] == i).center],bins);
%     plot(bins,N,'Color',colors(i,:));
    fitsOI = fitsOI.bin_fits;
    plot_cdf([fitsOI([fitsOI.bin] == i).center],bins,'Color',colors(i,:));
    xlim(x_limits);
end

% imagesc(bins,5:10:95,N);
ylabel('Probability')
xlabel('Developmental time (sec)');

%% by behavior in CDF

colors = {'b-','m-','r-'};
for i = 1:num_clusters
    hold on
    plot_cdf([fitsOI.get_cluster(i).center],bins,colors{i});
    xlim(x_limits)
end

xlabel('Developmental time (sec)')
ylabel('Probability')
legend(behaviors{:})

%% behavior in count/PDF

colors = {'b','m','r'};
N = zeros(2,numel(bins));
for i = 1:num_clusters
    N(i,:) = hist([fitsOI([fitsOI.cluster_label]==i).center],bins);
end

N = bsxfun(@rdivide, N, sum(N,2));

h = bar(bins,N','LineStyle','None');
for i = 1:num_clusters
    set(h(i),'FaceColor',colors{i});
end
legend(behaviors{:})
xlabel('Developmental time (sec)')
ylabel('Probability')
xlim(x_limits)

%% behavior by temporal bins

left = [-Inf	0];
right = [Inf  Inf];
N = zeros( numel(left), 6);
for i = 1:numel(left)
    
    filter = @(x) ([x.center] > left(i) & [x.center] <= right(i));
    N(i,:) = hist( [fitsOI(filter(fitsOI)).cluster_label], 1:6);
    
end
%filter out non-clustered pulses
N(:,num_clusters+1) = [];

h = bar(1:numel(left), bsxfun(@rdivide,N,sum(N,2)), 'stacked','LineStyle','none');

for i = 1:2
    set(h(i),'FaceColor',colors{i});
end
legend([behaviors,'N/A']);
ylabel('Count');
