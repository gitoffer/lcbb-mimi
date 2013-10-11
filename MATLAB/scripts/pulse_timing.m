% Pulse timing 

fitsOI = fits_wt;
bins = linspace(-500,500,30);

%% by bin

colors = pmkmp(13);

N = zeros(10,numel(bins));
for i = 1:10
    hold on;
    plot_cdf( [fitsOI([fitsOI.bin]==i).center],bins,'Color',colors(i,:) );
    N(i,:) = hist([fitsOI([fitsOI.bin] == i).center],bins);
    plot(bins,N,'Color',colors(i,:));
    xlim([-300 250]);
end

% imagesc(bins,5:10:95,N);
ylabel('Strength %-tile')
xlabel('Developmental time (sec)');

%% by behavior in CDF

colors = {'b-','c-','g-','m-','r-'};
for i = [1 4]
    hold on
    plot_cdf([fitsOI([fitsOI.cluster_label]==i).center],bins,colors{i});
    xlim([-300 300])
end
xlabel('Developmental time (sec)')
ylabel('CDF')
legend(entries{:})

%% behavior in count/PDF
bins = linspace(-500,500,30);

colors = {'b','c','g','m','r'};
N = zeros(2,numel(bins));
for i = [1 4]
    N(i,:) = hist([fitsOI([fitsOI.cluster_label]==i).center],bins);
end

N = bsxfun(@rdivide, N, sum(N,2));

h = bar(bins,N','LineStyle','None');
for i = [1 4]
    set(h(i),'FaceColor',colors{i});
end
legend(entries{:})
xlabel('Developmental time (sec)')
ylabel('Probability')
xlim([-300 300])

%% behavior by temporal bins

left = [-Inf    -Inf    0   60  120 180];
right = [Inf    0       60  120 180 Inf];
N = zeros( numel(left), 6);
for i = 1:numel(left)
    
    filter = @(x) ([x.center] > left(i) & [x.center] <= right(i));
    N(i,:) = hist( [fitsOI(filter(fitsOI)).cluster_label], 1:6);
    
end
h = bar(1:numel(left)-1, N(2:end,:),'LineStyle','none');
for i = 1:6
    set(h(i),'FaceColor',colors{i});
end
legend([entries,'N/A']);
ylabel('Count');
