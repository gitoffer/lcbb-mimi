function P = plot_peak_color(params,t)

n_peaks = size(params,2);

C = hsv(n_peaks);
C = C(randperm(n_peaks),:);

P = zeros(numel(t),3);
for i = 1:n_peaks
    
    this_peak = lsq_gauss1d(params(:,i),t);
    P = P + (C(i,:)'*this_peak)';
    
end