
Nboot = 50;

fitsOI = fits_twist;
cellsOI = cells_twist;
freqOI = freq_twist;

traceback = 'off';

%%

[phat,pci] = gamfit([freqOI{:}]);
frequency.fun = @(x) gamcdf(x,phat(1),phat(2));

pc_emp = [cellsOI.get_curated.num_fits];
N_pulse_count = hist(pc_emp,0:20);
N_pulse_count = cumsum(N_pulse_count)/sum(N_pulse_count);

p = cell(1,Nboot);
seq = cell(1,Nboot);

for i = 1:Nboot
    
    [p{i},seq{i}] = simulate_pulsing( ...
        cellsOI,fitsOI,frequency,N_pulse_count);
    
    display(['Done with ' num2str(i)]);
    
    for embryoID = [1 6 7]
        
        this_p = p{i}([p{i}.embryoID] == embryoID);
        
        if embryoID == 1, embryoID = 8; end
        
        fIDs = cat(1,this_p.fitID);
        cy = cat(1,this_p.centroid_y);
        cx = cat(1,this_p.centroid_x);
        ct = cat(1,this_p.center);
        l = cat(1,this_p.cluster_label);
        
        M = cat(2,fIDs,cx,cy,ct,l);
        path = ['~/Desktop/Pulse xyt csv/Embryo ' ...
            num2str(embryoID) '/simulated/emb' num2str(embryoID) '_N' num2str(i) '.csv'];
        
        csvwrite(path,M);
        
    end
end

%%

if strcmpi(traceback,'on')
    opt_tag = '_traceback';
else
    opt_tag = '';
end

for i = 1:Nboot
    
    [fits_bs_cell,cells_bs_cell] = cellsOI.bootstrap_stackID(fitsOI);
    
    for embryoID = [1]
        
        this_fits = fits_bs_cell.get_embryoID(embryoID);
        
        fits_bs_cell.get_embryoID(embryoID).export_xyt(cells_bs_cell,path,traceback);
        if embryoID == 1, embryoID = 8; end
        path = ['~/Desktop/Pulse xyt csv/Embryo ' ...
            num2str(embryoID) '/random_cell/emb' ...
            num2str(embryoID) '_N' num2str(i) opt_tag '.csv'];
        
        this_fits.export_xyt(cells_bs_cell,path);
        
    end
    
    display(['Done with ' num2str(i)]);
    
end
