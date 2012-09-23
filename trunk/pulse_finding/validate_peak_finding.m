
% Domain (time)
sec_per_frame = 6;
x = (0:60)*sec_per_frame;

clear peak_separation num_peaks noise_ratio noise_sigma_ratio

% Number of peaks
k = 2;
% C = hsv(10);

for l = 1:10
    for i = 1:10
        for j = 1:100
            
            % Parameters
            mu = [50 50+32];
            %         mu = [100 100+8*i];
            %         mu = randi(floor(max(x))-32, [1 k])+16;
            sigma = ones(1,k) + 4 + 2*l;
            A = 10*i+randn(1,k)*20;
            params = cat(1,A,mu,sigma);
            
            noise_size = 10;
            noise = randn(size(x))*noise_size;
            
            % Make the curve-to-fit
            y = synthesize_gaussians(params,x) + noise;
            
            [p] = iterative_gaussian_fit(y,x,.01,[0 0 5],[Inf max(x) 50]);
            residuals(i,j,:) = y - synthesize_gaussians(p,x);
            resnorm(i,j) = sum(residuals(i,j,:).^2);
            
            %             separation = min(diff(sort(mu,'ascend')));
            %             peak_separation(i,j) = separation;
            num_peaks(l,i,j) = size(p,2);
        end
        noise_ratio(l,i) = noise_size/(10*i);
        noise_sigma_ratio(l,i) = noise_size/4*i;
    end
end


%%

figure
C = varycolor(10);

for l = 1:10
    for i = 1:10
        for j = unique(squeeze(num_peaks(l,i,:)))'
            foo = num_peaks(l,i,:) - 2;
            perc_accurate(l,i) = numel(foo(foo == 0)) / 100;
            nearest = find(perc_accurate == .9);
            
            %             h(i) = draw_circle([noise_ratio(l,i,1) 10*l/4/i],perc_accurate,1000,'--');
            %             set(h(i),'color',C(l,:));
            %             axis equal
            %             hold on
        end
    end
end
% xlabel('Noise amlitude / signal amplitude')
ylabel('Number of detected peaks')

%%

imagesc(noise_ratio(1,1:3,1),noise_sigma_ratio(1,1:3),perc_accurate)
% imagesc(perc_accurate)

