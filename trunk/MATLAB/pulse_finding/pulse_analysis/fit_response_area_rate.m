%% fit response area_rate

params = nan(num_peaks,4);
fits = nan(size(corrected_area_rate));
res = nan(size(corrected_area_rate));
opt.fun = @lsq_gauss1d_offset;

for i = 1:num_peaks
    response = corrected_area_rate(i,:);
    if numel(response(~isnan(response))) > 5
        [response,idx] = interp_and_truncate_nan(response);
        opt.t = dt(idx:idx+numel(response)-1);
        opt.guess = [max(response) 0 10 mean(response)];
        opt.lb = [0 opt.t(1) opt.t(2)-opt.t(1) min(response)];
        opt.ub = [inf opt.t(end) opt.t(end)-opt.t(1) max(response)];

        [params(i,:),fits(i,idx:idx+numel(response)-1),res(i,idx:idx+numel(response)-1)] = ...
            fit_response(response,opt);
        
    end
end
