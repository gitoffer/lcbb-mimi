% Domain (time)
sec_per_frame = 8;
x = (1:50)*sec_per_frame;

% Number of peaks
k = 4;

for i = 1:1

% Centers
mu = randi(floor(max(x)),[1,k]);
% mu = [100 150 200 ];
sigma = (randn(1,k)/2+2)*sec_per_frame;
A = abs(10*randn(1,k)) + 1;

params = cat(1,A,mu,sigma)

y = synthesize_gaussians(x,params);

[p] = iterative_gaussian_fit(y,x,.05,[0 0 0],[Inf max(x) 5*sec_per_frame])
y_hat = synthesize_gaussians(x,p);

plot(y);
title('Original signal');

hold on;
plot(y_hat,'r-');
hold off;

separation = sort(diff(sort(mu)),'descend');
peak_separation(i) = separation(1);
num_peaks(i) = size(p,2);

end

%%
scatter(peak_separation,num_peaks);

%%