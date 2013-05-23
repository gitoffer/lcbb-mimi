%% Pulse frequency

fits_incell = cellfun(@fits.get_fitID,{cells.fitID},'UniformOutput',0);

freq = cellfun(@(x) diff(sort(x)), fits_incell,'UniformOutput',0);
