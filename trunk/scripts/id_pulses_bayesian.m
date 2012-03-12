%ID_PULSES_BAYESIAN

%% Simulate data
x = 1:100;
signal = 30*exp(-((x-50).^2)/30) + 150*exp(-((x-70).^2)/30);
signal = signal + 500*exp(-((x-130).^2)/2000);
signal = signal + x - 50;
signal = signal + 20*randn(size(x));
signal(signal < 0) = 0;
plot(signal,'r-');

%%
cellID = 44;

myosin_sm = smooth2a(squeeze(myosins(:,zslice,cellID)),1,0);

signal = interp_and_truncate_nan(myosin_sm);

%% Set up models

h.peak_function = @lsq_gauss1d;
h.background_function = @lsq_linear;
h.num_parameter = [3 2];
Amax = sum(signal);
xmax = numel(signal);
h.parameter_bounds = [Amax 0 xmax];

%%

[P b] = bayes_peak_find(signal,1:numel(signal),10,h);
P
[~,I] = max(P);
fitted = construct_mpeaks(1:numel(signal),b{I},h);
plot(signal,'r-');hold on,plot(fitted)