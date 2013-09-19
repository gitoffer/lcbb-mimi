% Pulse timing 

fitsOI = fits_wt;
bins = linspace(-500,500,50);

%% by bin

% N1 = hist([fits([fits.bin]==1).center],bins);
% N2 = hist([fits([fits.bin]==2).center],bins);
% N3 = hist([fits([fits.bin]==3).center],bins);
% N4 = hist([fits([fits.bin]==4).center],bins);
% 
% bar(bins,cat(1,N1,N2,N3,N4)');

colors = varycolor(10);

for i = 1:10
    hold on;
    plot_cdf( [fitsOI([fitsOI.bin]==i).center],bins,'Color',colors(i,:) );
    xlim([-300 250]);
end

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

%%