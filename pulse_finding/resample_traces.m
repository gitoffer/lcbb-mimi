function [aligned_traces,aligned_time] = resample_traces(traces,embryoIDs,dt,opt)
%RESAMPLE_TRACES Uses INTERP1 to resample short traces
%
% [aligned_traces,aligned_time] = resample_traces(traces,embryoID,dt);
%
% xies@mit.edu Oct 2012

num_traces = size(traces,1);
T = size(traces,2);

aligned_traces = zeros(size(traces));

num_embryos = numel(dt);

if numel(embryoIDs) ~= num_traces
    error('The number of traces and the number of embryoID must be the same.');
end

aligned_dt = round(mean(dt)*100)/100;
l = opt.left_margin; r = opt.right_margin;
% w = floor(T/2);

aligned_traces = zeros([num_traces, l + r - 3]);

% Resample using the SIGNAL_PROCESSING TOOLBOX
for i = 1:num_traces
    aligned_traces(i,:) = ...
        interp1((-l:r)*dt(embryoIDs(i)),traces(i,:),(-(l-2):r-2)*aligned_dt);
end

aligned_time = (-(l-2):r-2)*aligned_dt;
% aligned_time = (0:(length(y)-1))*2/(3*fs1);  % New time vector

end
