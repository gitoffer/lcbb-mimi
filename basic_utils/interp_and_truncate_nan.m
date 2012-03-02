function signal_int = interp_and_truncate_nan(signal)

X = 1:numel(signal);
signal_int = interp1(X(~isnan(signal)),signal(~isnan(signal)),X);

% Change first chunk of NAN into 0
I = find(~isnan(signal_int),1);
signal_int(1:I) = 0;

% Delete later NaN
I = find(isnan(signal_int),1);
signal_int(I:end) = [];