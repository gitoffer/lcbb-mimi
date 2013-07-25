function M = get_corrected_pulse_measurement(fits,meas,input,fit_opts)

fits = fits.align_fits(meas,'measurement',fit_opts);
fits = fits.resample_traces('measurement',[input.dt],fit_opts);
M = cat(1,fits.corrected_measurement);

end