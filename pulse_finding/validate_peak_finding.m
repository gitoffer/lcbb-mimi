
% Domain (time)
sec_per_frame = 6;
x = (0:60)*sec_per_frame;

clear peak_separation num_peaks noise_ratio noise_sigma_ratio

% Number of peaks
k = 2;
% C = hsv(10);

p = cell(10,10,100);

for l = 1:10
    for i = 1:10
        for j = 1:100
            
            % Parameters
            mu = [50 50+32];
            
            sigma = ones(1,k) + 4 + 2*l;
            A = 10*i+ones(1,k)*10;
            params = cat(1,A,mu,sigma);
            
            noise_size = 10;
            noise = randn(size(x))*noise_size;
            
            % Make the curve-to-fit
            y = synthesize_gaussians(params,x) + noise;
            
            % Get fitted parameters
            p{l,i,j} = iterative_gaussian_fit(y,x,.01,[0 0 5],[Inf max(x) 50]);
            residuals(i,j,:) = y - synthesize_gaussians(p{l,i,j},x);
            resnorm(i,j) = sum(residuals(i,j,:).^2);
            
            num_peaks(l,i,j) = size(p{l,i,j},2);
        end
        noise_ratio(l,i) = noise_size/A(1);
        noise_sigma_ratio(l,i) = noise_size/sigma(1);
    end
end


%%

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
% ylabel('Number of detected peaks')

%%

h = imagesc(1./noise_ratio(1,end:-1:1),1./noise_sigma_ratio(:,1),perc_accurate);
xlabel('A/n_l')
ylabel('\sigma/n_l')
title('Accuracy of inferred number of peaks')
caxis([0 1]);
colorbar
saveas(h,'~/Desktop/Peak Detection testing/Synthetic data/k=2/r2_A_sigma.fig')
saveas(h,'~/Desktop/Peak Detection testing/Synthetic data/k=2/r2_A_sigma.eps')

%% Parameter accuracy

for l = 1:10
    for i = 1:10
        for j = 1:10
            % Only correct number inference
            if num_peaks(l,i,j) -k == 0
                % heights
                p{l,i,j} = 
            end
        end
    end
end

