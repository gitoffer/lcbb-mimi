% Domain (time)
sec_per_frame = 6;
x = (0:60)*sec_per_frame;

clear peak_separation num_peaks

% Number of peaks
k = 4;
% C = hsv(10);

for i = 1:20
    for j = 1:100
        
        % Parameters
        mu = [50 50+48 50+96 50+144];
        %         mu = [100 100+8*i];
        %         mu = randi(floor(max(x))-32, [1 k])+16;
        sigma = ones(1,k) + 16;
        A = 100+randn(1,k)*20;
        params = cat(1,A,mu,sigma);
        
        noise_size = 5*i;
        noise = randn(size(x))*noise_size;
        
        % Make the curve-to-fit
        y = synthesize_gaussians(params,x) + noise;
        
        [p] = iterative_gaussian_fit(y,x,.01,[0 0 10],[Inf max(x) 20]);
        residuals(i,j,:) = y - synthesize_gaussians(p,x);
        resnorm(i,j) = sum(residuals(i,j,:).^2);
        
        separation = min(diff(sort(mu,'ascend')));
        peak_separation(i,j) = separation;
        noise_level(i,j) = noise_size;
        num_peaks(i,j) = size(p,2);
        
        %         l = min(k(i),size(p,2));
        %         [~,I] = sort(params(1,:),'descend');
        %         [~,J] = sort(p(1,:),'descend');
        %         I = I(1:l);
        %         J = J(1:l);
        %
        %         if separation > 32
        %             heights(i,j) = mean(params(1,I) - p(1,J));
        %             centers(i,j) = mean(params(2,I) - p(2,J));
        %             widths(i,j) = mean(params(3,I) - p(3,J));
        %         else
        %             heights(i,j) = NaN;
        %             centers(i,j) = NaN;
        %             widths(i,j) = NaN;
        %         end
        %
        %         if abs(heights(i,j)) > 10
        %             keyboard
        %         end
        
    end
end

%%
clf
for i = 1:10
    for j = unique(num_peaks(i,:))
        foo = num_peaks(i,:);
        h(i) = draw_circle([peak_separation(i,1)*10 (j)*100],numel(foo(foo==j))/3,1000,'--');
        %         set(h(i),'color',C(i,:));
        axis equal
        hold on
    end
end
% xlabel('Noise amlitude / signal amplitude')
ylabel('Number of detected peaks')

%%

C = hsv(5);

% delta_k = bsxfun(@minus,num_peaks,k');
delta_k = num_peaks - 2;
for i = 1:5
    scatter(min_peak_size(i,:),delta_k(i,:) + .1*i,100,C(i,:),'filled');
    hold on
    xlabel('Mean separation between peaks (sec)');
    ylabel('\Delta k, difference between inferred number of peaks and actual k')
end

%%

showsub_vert(...
    @hist,{flat(heights),20},'Difference in height (a.u.)','',...
    @hist,{flat(centers),20},'Difference in mean (sec)','',...
    @hist,{flat(widths),20},'Difference in width (sec)','',...
    3);

%%
clear peak_separation num_peaks

k = 2;
bg_myosin = nanmean(smooth2a(myosins_sm,5,0),2)';
bg_myosin = bg_myosin(1:30);
x = (1:30)*sec_per_frame;

for i = 1
    for j = 1:1
        mu = [50 160+10];
        %         mu = [100 100+8*i];
        %         mu = randi(floor(max(x))-32, [1 k])+16;
        sigma = 16*ones(1,k);
        A = [100 500];
        params = cat(1,A,mu,sigma);
        
        noise_size = 10;
        noise = randn(size(x))*noise_size;
        
        % Make the curve-to-fit
        y = synthesize_gaussians(params,x) + noise + bg_myosin;
        %         foo(j,:) = y;
        dy = central_diff(y,x);
        dy(dy < 0) = 0;
        
        %         bar(j,:) = dy;
        
        [p] = iterative_gaussian_fit(dy,x,.01,[0 0 10],[Inf max(x) 20]);
        
        figure
        plotyy(x,y,x,dy),legend('Simulated myosin','Simulated myosin rate')
        figure
        plotyy(x,dy,x,synthesize_gaussians(p,x));
        
        %     residuals(i,j,:) = y - synthesize_gaussians(p,x);
        %     resnorm(i,j) = sum(residuals(i,j,:).^2);
        %
        separation = min(diff(sort(mu,'ascend')));
        peak_separation(i,j) = separation;
        min_peak_size(i,j) = max(A)/min(A);
        %     noise_level(i,j) = noise_size;
        num_peaks(i,j) = size(p,2);
        %         title(['Separation ' num2str(separation), ' sec']);
    end
end





