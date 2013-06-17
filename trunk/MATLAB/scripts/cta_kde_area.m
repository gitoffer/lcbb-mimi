%% cta KDE area
% KDE estimates of cta area distribution

embryoID = 1:5;
kernel_size = 2.5; % um^2
kde_nbin = 100;
slice_window = 30; % seconds

[est,est_bins,tbins,Ninslice] = kde_gauss_temporal_binning( ...
    embryo_stack(embryoID), kde_nbin, slice_window, kernel_size, @gaussian_derivative);

C = varycolor(numel(tbins)-1);
set(gca,'ColorOrder',C);
set(gca,'NextPlot','replacechildren')
plot(bins,est);
legend(num2str(tbins(:)));

% figure
% subplot(4,1,1:3);
% imagesc( tbins, est_bins, est');
% axis xy
% xlabel('Developmental time'); ylabel('Area (\mum^2)')
% 
% subplot(4,1,4);
% plot( tbins, Ninslice );
% xlim( [tbins(1) tbins(end)] )
% ylabel('Number of cells in bin')
