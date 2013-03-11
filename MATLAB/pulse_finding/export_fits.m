function export_fits(fits,filepath,fieldname)

% num_fits = numel(fits);

% mat2write = zeros(numel(fits)

fitIDs = [fits.fitID]';
manual_flag = [fits.manually_added]';

mat2write = cat(2,fitIDs,manual_flag);

data = cat(1,fits.(fieldname));

mat2write = cat(2,mat2write,data);

header = [NaN NaN 1:numel(fits(1).(fieldname))];

mat2write = cat(1,header,mat2write);

csvwrite([filepath '/fits_' fieldname,'.csv'] , mat2write);

end