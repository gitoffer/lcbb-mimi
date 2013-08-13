%% Pulse frequency
% Wildtype

fits_incell = cellfun(@fits_bs.get_fitID,{cells_bs.get_embryoID(1:5).fitID},'UniformOutput',0);

fits_center_incell = cell(1,numel(fits_incell));
for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_wt = cellfun(@(x) diff(sort(x)), fits_center_incell,'UniformOutput',0);

[N_wt,bins] = hist( [freq_wt{:}], 30);
bar( bins, N_wt/sum(N_wt) );
xlabel('Time between pulses (sec)')
ylabel('Probability')
title('Wild-type')

%% twist

twist_cells = cells( ismember([cells.embryoID], [6,7]) );

fits_incell = cellfun(@fits_all.get_fitID,{twist_cells.fitID},'UniformOutput',0);

fits_center_incell = cell(1,numel(fits_incell));

for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_twist = cellfun(@(x) diff(sort(x)), fits_center_incell, 'UniformOutput',0);

%% cta (seperate two cta populations)... see cta_clustering.m

cta_cells8 = cells( [cells.embryoID] == 8 );
cta_cells9 = cells( [cells.embryoID] == 9 );

fits_incell8 = cellfun(@fits_all.get_fitID, ...
    {cells(  c8([cta_cells8.cellID]) == 1 ).fitID}, 'UniformOutput', 0);
fits_incell9 = cellfun(@fits_all.get_fitID, ...
    {cells(  c9([cta_cells9.cellID]) == 1 ).fitID}, 'UniformOutput', 0);
fits_incell = [fits_incell8, fits_incell9];

fits_center_incell = cell(1,numel(fits_incell));
for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_cta1 = cellfun(@(x) diff(sort(x)), fits_center_incell, 'UniformOutput',0);


fits_incell8 = cellfun(@fits_all.get_fitID, ...
    {cells(  c8([cta_cells8.cellID]) == 2 ).fitID}, 'UniformOutput', 0);
fits_incell9 = cellfun(@fits_all.get_fitID, ...
    {cells(  c9([cta_cells9.cellID]) == 2 ).fitID}, 'UniformOutput', 0);
fits_incell = [fits_incell8, fits_incell9];

fits_center_incell = cell(1,numel(fits_incell));
for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_cta2 = cellfun(@(x) diff(sort(x)), fits_center_incell, 'UniformOutput',0);

%% Plot results as histograms

bins = linspace(0,250,50);

[N_wt, bins] = hist( [freq_wt{:}] , bins);
[N_twist,bins] = hist( [freq_twist{:}], bins);
[N_cta1, bins] = hist( [freq_cta1{:}] , bins);
[N_cta2, bins] = hist( [freq_cta2{:}] , bins);
N_cta = N_cta1 + N_cta2;

bar( bins, ... 
    cat( 1,N_wt/sum(N_wt), ...
    N_cta/sum(N_cta), ...
    N_twist/sum(N_twist) ...
    )', 'Grouped');

set(gca,'XLim',[0 250]);

xlabel('Period between pulses (sec)')
ylabel('Probability')
legend(['Wild-type, N = ' num2str(sum(N_wt))], ...
    ['cta, N = ' num2str(sum(N_cta))], ...
    ['twist, N = ' num2str(sum(N_twist))] ...
    );

figure, bar( bins, cat(1,N_cta1/sum(N_cta1), N_cta2/sum(N_cta2))' ,'Grouped');
set(gca,'Xlim',[0 250]);
xlabel('Period between pulses (sec)')
ylabel('Probability')
legend(['cta (constricting), N = ' num2str(sum(N_cta1))], ...
    ['cta (expanding), N = ' num2str(sum(N_cta2))] ...
    );

%% Count number of pulses per cell for different genotypes

N_wt = hist( [cells( [cells.embryoID] < 6 ).num_fits] , 1:15);
N_twist = hist( [cells( ismember([cells.embryoID], [6 7]) ).num_fits] ,1:15);
N_cta = hist( [cells( [cells.embryoID] > 7 ).num_fits] ,1:15);

bar(1:15, ...
    cat( 1, N_wt, N_twist, N_cta)' );

legend(['Wild-type, cells = ' num2str(sum(N_wt))], ...
    ['twist, cells = ' num2str(sum(N_twist))], ...
    ['cta, cells = ' num2str(sum(N_cta))] ...
    );


