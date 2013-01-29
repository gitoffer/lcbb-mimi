function [resp,IDs] = filter_pulse_response(resp,thresh)

% [~,T] = size(resp);
% if T ~= numel(corrected_time)
%     error('Response matrix must have the same number of time points as time vector!');
% end

IDs = find(any(resp > thresh,2));

resp = resp(IDs,:);

end