
%%
clear fit_opts
[fit_opts(1:num_embryos).to_fit] = deal('myosin_intensity');
[fit_opts(1:num_embryos).bg] = deal('on');

[fit_opts(1:num_embryos).left_margin] = deal(8);
[fit_opts(1:num_embryos).right_margin] = deal(10);
[fit_opts(1:num_embryos).nan_thresh] = deal(30);
[fit_opts(1:num_embryos).nan_consec_thresh] = deal(5);
[fit_opts(1:num_embryos).end_tol] = deal(30);

[fit_opts(1:num_embryos).alpha] = deal(0.01);
[fit_opts(1:num_embryos).sigma_lb] = deal(10);
[fit_opts(1:num_embryos).sigma_ub] = deal(30);

% [fit_opts(8:9).alpha] = deal(0.05);
% [fit_opts(8:9).sigma_lb] = deal(5);
% [fit_opts(8:9).sigma_ub] = deal(45);

%% Perform fitting

if ~exist('cells','var'), cells = embryo2cell(embryo_stack); end
[cells_raw,fits_raw] = fit_gaussians(cells,fit_opts);
save('~/Desktop/fits_raw.mat','fits_raw','cells_raw')

%% sub-set of pulses

fits = fits.retrace(cells,fit_opts);

fits_wt = fits.get_embryoID(1:5);
fits_twist = fits.get_embryoID(6:7);
fits_cta = fits.get_embryoID(8:10);

%% Align all pulses

fits = fits.align_fits(myosins,'myosin');
fits = fits.align_fits(areas_sm,'area');
fits = fits.align_fits(areas_rate,'area_rate');
fits = fits.align_fits(myosins_rate,'myosin_rate');
% fits = fits.align_fits(anisotropies,'anisotropy');
fits = fits.align_fits(myosin_ring1+myosin_ring2,'measurement');

aligned_area = cat(1,fits.area);
aligned_myosin = cat(1,fits.myosin);
aligned_area_rate = cat(1,fits.area_rate);
aligned_myosin_rate = cat(1,fits.myosin_rate);
aligned_measurement = cat(1,fits.measurement);

% Mean-center pulses responses
aligned_area_norm = bsxfun(@minus,aligned_area,nanmean(aligned_area,2));
% aligned_myosin = bsxfun(@minus,aligned_myosin,nanmean(aligned_myosin,2));
% aligned_measurement = bsxfun(@minus,aligned_measurement,nanmean(aligned_measurement,2));
fits = assign_datafield(fits,aligned_area_norm,'area_norm');
fits = assign_datafield(fits,aligned_myosin,'myosin');
fits = assign_datafield(fits,aligned_measurement,'measurement');

% [aligned_area_norm,cols_left] = delete_nan_rows(aligned_area_norm,2);
% aligned_myosin = aligned_myosin(:,cols_left);
% aligned_area_rate = aligned_area_rate(:,cols_left);
% aligned_myosin_rate = aligned_myosin_rate(:,cols_left);
% aligned_area = aligned_area(:,cols_left);
% time = time(:,cols_left);

% correlate for framerate differences
fits = resample_traces(fits,'area_norm',[input.dt]);
fits = resample_traces(fits,'area',[input.dt]);
fits = resample_traces(fits,'myosin',[input.dt]);
fits = resample_traces(fits,'area_rate',[input.dt]);
fits = resample_traces(fits,'measurement',[input.dt]);

corrected_area = cat(1, fits.corrected_area);
corrected_area_norm = cat(1, fits.corrected_area_norm);
corrected_area_rate = cat(1, fits.corrected_area_rate);
corrected_myosin = cat(1, fits.corrected_myosin);

fits_wt = fits([fits.embryoID] < 6);
fits_twist = fits([fits.embryoID] > 5 & [fits.embryoID] < 8);
fits_cta = fits([fits.embryoID] > 7);
