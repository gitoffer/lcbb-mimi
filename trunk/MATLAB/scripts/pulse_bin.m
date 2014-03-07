% Pulse strength

fitsOI = fits.get_embryoID(6:10);
fitsOI = fitsOI.bin_fits;

%%

N = zeros(10,num_clusters);
for i = 1:num_clusters
    
    N(:,i) = hist([fitsOI.get_cluster(i).bin]);
    
end

N = bsxfun(@rdivide,N,sum(N))';

figure(1)
bar(N,'stacked');
set(gca,'XTickLabel',behaviors);
ylabel('Probability')
ylim([0 1])
colormap(pmkmp(10))

figure(2)
plot(cumsum(N,2)');
legend(behaviors{:});
ylabel('Cumulative probability')

%%

