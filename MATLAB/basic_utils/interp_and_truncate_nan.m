function [signal_int,start,endI] = interp_and_truncate_nan(signal)
%INTERP_AND_TRUNCATER_NAN: Interpolates the input SIGNAL and truncates
%trailing NaNs. Will set first NaNs to 0, but will also return the true
%"start" index.
%
% SYNOPSIS: [s_interp, start] = interp_and_truncate_nan(signal);
%
% xies@mit.edu


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

endI = I - 1;
if isempty(endI), endI = numel(signal); end

end