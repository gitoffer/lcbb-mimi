%% cta KDE area
% KDE estimates of cta area distribution

embryoID = 1:5;
kernel_size = 3; % um^2
kde_bins = linspace(0,80,1024);
slice_window = input(8).dt*5; % seconds

% Temporal slicing
[sliceID,tbins,Ninslice] = temporally_slice(embryo_stack(embryoID),slice_window);

% KDE
[est,est_bins,Nzeros,h] = kde_gauss( ...
    embryo_stack(embryoID), kde_bins, sliceID, kernel_size);

C = varycolor(numel(tbins));
set(gca,'ColorOrder',C);
set(gca,'NextPlot','replacechildren')
plot(est_bins,est);
legend(num2str(tbins(:)));

%% Find h_critical & mode distribution

k_mode = 1; % test for not-unimodality
h_scan = 1:0.1:6; % scanning

[h_crit,Nmodes] = get_hcrit(cat(2,embryo_stack(embryoID).area),kde_bins,k_mode,h_scan,sliceID);

plot(tbins,h_crit);
xlabel('Developmental time (sec)')
ylabel('Critical h-size for unimodal (\mum^2)');

%% Plot

figure
subplot(5,1,1:3);
[X,Y] = meshgrid(tbins,est_bins);
pcolor( X, Y, est');shading flat
axis xy
xlabel('Developmental time'); ylabel('Area (\mum^2)')

subplot(5,1,4);
plot( tbins, Nzeros );
xlim( [tbins(1) tbins(end)] )
ylabel('Number of modes')

subplot(5,1,5);
imagesc( tbins, h_scan, Nmodes' );
axis xy
xlim( [tbins(1) tbins(end)] )
caxis( [1 10] ),colorbar;
ylabel('Kernel size')

%% Bootstrap testing for significance at each temporal slice

Nboot = 100;
Nslice = numel(unique(sliceID)) - 1;
Nmodes_bs = zeros(Nslice,Nboot);
data = cat(2,embryo_stack(embryoID).area);
% matlabpool open 4

for i = 1:Nslice
    data_within_slice = nonans(data(sliceID == i));
    Nmodes_bs(i,:) = ...
        bootstrp(Nboot,@(x) count_modes_gaussian(h_crit(i),x,kde_bins),data_within_slice);
    P(i) = find( sort(Nmodes(i,:)) == 1, 1, 'last')/Nboot;
    display(['Done with slice: ' num2str(i) ]);
end
% matlabpool close

%%

data = cat(2,embryo_stack(embryoID).area);
Nslice = numel(unique(sliceID)) - 1;

set(gca,'ColorOrder',C);
hold all
for i = 1:Nslice
    
    data_within_slice = nonans(data(sliceID == i));
    plot_cdf( data_within_slice, kde_bins);
    
end