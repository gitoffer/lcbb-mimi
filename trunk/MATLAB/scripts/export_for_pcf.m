traceback = 'on';

if strcmpi(traceback,'on')
    opt_tag = '_traceback';
else
    opt_tag = '';
end

%%

for embryoID = 7
    path = ['~/Desktop/Pulse xyt csv/Embryo ' ...
        num2str(embryoID) '/emb' num2str(embryoID) '_emp' opt_tag '.csv'];
    fits.get_embryoID(embryoID).export_xyt(cells,path,traceback);
end

%% random_cell
Nboot = 50;

for i = 1:Nboot
    tic
    [fits_bs_cell,cells_bs_cell] = cells.bootstrap_stackID(fits);
    for embryoID = [6 8]
        path = ['~/Desktop/Pulse xyt csv/Embryo ' ...
            num2str(embryoID) '/random_cell/emb' ...
            num2str(embryoID) '_N' num2str(i) opt_tag '.csv'];
        fits_bs_cell.get_embryoID(embryoID).export_xyt(cells_bs_cell,path,traceback);
    end
    toc
    i
end
