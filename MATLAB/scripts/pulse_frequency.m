%% Pulse frequency
% Wildtype

fits_incell = cellfun(@fits_all.get_fitID,{cells([cells.embryoID] < 6).fitID},'UniformOutput',0);

fits_center_incell = cell(1,numel(fits_incell));
for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_wt = cellfun(@(x) diff(sort(x)), fits_center_incell,'UniformOutput',0);

%%

hist([freq_wt{:}], 30)
xlabel('Period between pulses')
ylabel('Counts')
title('Wild-type')

%% twist

twist_cells = cells( ismember([cells.embryoID], [6,7]) );

fits_incell = cellfun(@fits_all.get_fitID,{twist_cells.fitID},'UniformOutput',0);

fits_center_incell = cell(1,numel(fits_incell));

for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_twist = cellfun(@(x) diff(sort(x)), fits_center_incell, 'UniformOutput',0);

%% cta

cta_cells8 = cells( [cells.embryoID] == 8 );
cta_cells9 = cells( [cells.embryoID] == 9 );

fits_incell8 = cellfun(@fits_all.get_fitID, ...
    {cells(  c([cta_cells8.cellID]) == 1 ).fitID}, 'UniformOutput', 0);
fits_incell9 = cellfun(@fits_all.get_fitID, ...
    {cells(  c9([cta_cells9.cellID]) == 1 ).fitID}, 'UniformOutput', 0);
fits_incell = [fits_incell8, fits_incell9];

fits_center_incell = cell(1,numel(fits_incell));
for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_cta1 = cellfun(@(x) diff(sort(x)), fits_center_incell, 'UniformOutput',0);


fits_incell8 = cellfun(@fits_all.get_fitID, ...
    {cells(  c([cta_cells8.cellID]) == 2 ).fitID}, 'UniformOutput', 0);
fits_incell9 = cellfun(@fits_all.get_fitID, ...
    {cells(  c9([cta_cells9.cellID]) == 2 ).fitID}, 'UniformOutput', 0);
fits_incell = [fits_incell8, fits_incell9];

fits_center_incell = cell(1,numel(fits_incell));
for i = 1:numel(fits_incell)
    fits_center_incell{i} = [fits_incell{i}.center];
end

freq_cta2 = cellfun(@(x) diff(sort(x)), fits_center_incell, 'UniformOutput',0);

%%

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

xlabel('Period between pulses')
ylabel('Probability')
legend(['Wild-type, N = ' num2str(sum(N_wt))], ...
    ['cta, N = ' num2str(sum(N_cta))], ...
    ['twist, N = ' num2str(sum(N_twist))] ...
    );
