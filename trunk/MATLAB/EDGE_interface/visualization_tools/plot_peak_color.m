function P = plot_peak_color(params,t,colororder)
%PLOT_PEAK_COLOR Plot pulses in specified color order
% Will use yellow-cyan alternatively if color order not defined.
%
% SYNOPSIS: P = plot_peak_color(params,t,colororder);
%
% xies@mit.

n_peaks = size(params,2);

[~,order] = sort(params(2,:),'ascend');
params = params(:,order);

% C = hsv(n_peaks);
% C = C(randperm(n_peaks),:);

P = zeros(numel(t),3);
for i = 1:n_peaks
    
    this_peak = lsq_gauss1d(params(:,i),t);
    if mod(i,2) == 0
        C = [0 1 1];
    else
        C = [1 1 0];
    end
    if nargin > 2
        C = colororder(i,:);
    end
    P = P + (C'*this_peak)';
    
end

end