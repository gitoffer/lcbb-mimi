function [signal_int,start] = interp_and_truncate_nan(signal)

X = 1:numel(signal);
signal_int = interp1(X(~isnan(signal)),signal(~isnan(signal)),X);

% Change first chunk of NAN into 0
I = find(~isnan(signal_int),1);
start = I;
signal_int_pad = signal_int;
signal_int_pad(1:I) = 0;

% Delete later NaN
I = find(isnan(signal_int_pad),1);
signal_int(I:end) = [];
signal_int(1:start-1) = [];

end