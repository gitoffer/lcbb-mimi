
%%

[fit_opts(1:num_embryos).to_fit] = deal('myosin_intensity_fuzzy');
[fit_opts(1:num_embryos).bg] = deal('on');

[fit_opts(1:num_embryos).left_margin] = deal(5);
[fit_opts(1:num_embryos).right_margin] = deal(5);
[fit_opts(1:num_embryos).nan_thresh] = deal(20);
[fit_opts(1:num_embryos).end_tol] = deal(30);

fit_opts(1).alpha = 0.01;
fit_opts(1).sigma_lb = 15;
fit_opts(1).sigma_ub = 50;

fit_opts(2).alpha = 0.01;
fit_opts(2).sigma_lb = 15;
fit_opts(2).sigma_ub = 50;

%%

embryo_stack = edge2embryo(EDGEstack,input,num_cells);
cells = edge2cell(embryo_stack);
[pulses,cells] = fit_gaussians(cells,fit_opts);

%% sub-set of pulses

% subIDs = intersect(find(1:numel(pulses) < wt_cutoff),filtIDs);
% sub_pulse = subID_pulses(pulses,subIDs);

pulsesOI
num_peaks = numel(pulseOI);

%% Align all pulses

[pulses,time] = align_peaks(pulses,myosins_sm,'myosin',fit_opts);
[pulses,~] = align_peaks(pulses,areas_sm,'area',fit_opts);
[pulses,~] = align_peaks(pulses,areas_rate,'area_rate',fit_opts);
[pulses,~] = align_peaks(pulses,myosins_rate,'myosin_rate',fit_opts);

aligned_area = cat(1,pulses.area);
aligned_myosin = cat(1,pulses.myosin);
aligned_area_rate = cat(1,pulses.area_rate);
aligned_myosin_rate = cat(1,pulses.myosin_rate);

% sort pulses based on their magnitude
[sorted_amplitudes,sortedID] = sort([pulses.amplitude],2,'descend');

% Mean-center pulses responses
aligned_area_norm = bsxfun(@minus,aligned_area,nanmean(aligned_area,2));
for i = 1:numel(pulses)
    pulses(i).area_norm = aligned_area_norm(i,:);
end

% [aligned_area_norm,cols_left] = delete_nan_rows(aligned_area_norm,2);
% aligned_myosin = aligned_myosin(:,cols_left);
% aligned_area_rate = aligned_area_rate(:,cols_left);
% aligned_myosin_rate = aligned_myosin_rate(:,cols_left);
% aligned_area = aligned_area(:,cols_left);
% time = time(:,cols_left);

% correlate for framerate differences
pulses = resample_traces(pulses,'area_norm',[input.dt],fit_opts);
pulses = resample_traces(pulses,'area',[input.dt],fit_opts);
pulses = resample_traces(pulses,'myosin',[input.dt],fit_opts);
pulses = resample_traces(pulses,'area_rate',[input.dt],fit_opts);

corrected_area = cat(1, pulses.area);
corrected_area_norm = cat(1, pulses.area_norm);
corrected_area_rate = cat(1, pulses.area_rate);
corrected_myosin = cat(1, pulses.myosin);
