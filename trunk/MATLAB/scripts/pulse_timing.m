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

colors = {'r-','b-','k-','g-'};

for i = 1:4
    hold on
    plot_cdf([fitsOI([fitsOI.bin]==i).center],bins,colors{i});
    xlim([-300 250]);
end

%% by behavior

colors = {'b-','c-','g-','m-','r-'};
for i = 1:5
    hold on
    plot_cdf([fitsOI([fitsOI.cluster_label]==i).center],bins,colors{i});
    xlim([-500 500])
end
legend(entries{:})

%% behavior in count/PDF

colors = {'b','c','g','m','r'};
N = zeros(5,numel(bins));
for i = 1:5
    N(i,:) = hist([fitsOI([fitsOI.cluster_label]==i).center],bins);
end
% set(gca,'ColorOrder',colors);
bar(bins,N');
xlim([-300 250])

%%