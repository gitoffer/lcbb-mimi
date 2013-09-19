% Pulse timing 

fitsOI = fits_wt;
bins = linspace(-500,500,50);

%% by bin

colors = pmkmp(13);

for i = 1:10
    hold on;
    plot_cdf( [fitsOI([fitsOI.bin]==i).center],bins,'Color',colors(i,:) );
    xlim([-300 250]);
end
xlabel('Developmental time (sec)');

%% by behavior

colors = {'b-','c-','g-','m-','r-'};
for i = 1:5
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
N = zeros(5,numel(bins));
for i = 1:5
    N(i,:) = hist([fitsOI([fitsOI.cluster_label]==i).center],bins);
end

h = plot(bins,bsxfun(@rdivide,N',sum(N')) );
for i = 1:5
    set(h(i),'Color',colors{i});
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
