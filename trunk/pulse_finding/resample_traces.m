function [aligned_traces,aligned_time] = resample_traces(traces,embryoIDs,dt)
%RESAMPLE_TRACES

num_traces = size(traces,1);
T = size(traces,2);

aligned_traces = zeros(size(traces));

num_embryos = numel(dt);

if numel(embryoIDs) ~= num_traces
    error('The number of traces and the number of embryoID must be the same.');
end

aligned_dt = round(mean(dt)*100)/100;
w = floor(T/2);

aligned_traces = zeros([num_traces, 2*(w-1)+1]);

% Resample using the SIGNAL_PROCESSING TOOLBOX
for i = 1:num_traces
    aligned_traces(i,:) = ...
        interp1((-w:w)*dt(embryoIDs(i)),traces(i,:),(-(w-1):w-1)*aligned_dt);
end

aligned_time = (-(w-1):w-1)*aligned_dt;
% aligned_time = (0:(length(y)-1))*2/(3*fs1);  % New time vector

end
