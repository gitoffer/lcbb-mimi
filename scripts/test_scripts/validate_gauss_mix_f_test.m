% Domain (time)
sec_per_frame = 6;
x = (0:60)*sec_per_frame;

clear peak_separation num_peaks bg_amplitude_ratio

num_peaks = zeros(10,10,100);

% Number of peaks
k = 2;
% C = hsv(10);
for l = 1:10
    for i = 1:10
        for j = 1:100
            
            % Parameters
            mu = [50 50+10*i];
            %         mu = [100 100+8*i];
            %         mu = randi(floor(max(x))-32, [1 k])+16;
            sigma = ones(1,k) + 16;
            A = ones(1,k)*100;
            params = cat(1,A,mu,sigma);
            
            noise_size = 10;
            noise = randn(size(x))*noise_size;
            
            % Make the curve-to-fit
            y = synthesize_gaussians(params,x) + noise;
            y = y + lsq_exponential([25*l 2 500],x);
            
            [p] = iterative_gaussian_fit(y,x,.01,[0;0;10],[Inf;max(x);30],'on');
            fitted_y = synthesize_gaussians_withbg(p,x);
            %         residuals(i,j,:) = y - synthesize_gaussians_withbg(p,x);
            %         resnorm(i,j) = sum(residuals(i,j,:).^2);
            
            separation = min(diff(sort(mu,'ascend')));
            delta_mu_sigma_ratio(l,i) = 10*(l);
            bg_amplitude_ratio(l,i) = noise_size/A(1);
            num_peaks(l,i,j) = size(p,2)-1;
            
            if i == 10
                [j,i]
            end
        end
    end
end

%%
figure
for i = 1:10
    for l = 1:10
        %     for j = unique(num_peaks(i,:))
        foo = num_peaks(l,i,:);
        %         h(i) = draw_circle([i*100 (j)*100],numel(foo(foo==j))/3,1000,'--');
        %         set(h(i),'color',C(i,:));
        perc_accurate(l,i) = numel(foo(foo == k))/100;
        axis equal
        hold on
    end
end
pcolor(perc_accurate);
xlabel('\Delta\mu/\sigma')
ylabel('A/Background')

%%

C = hsv(5);

% delta_k = bsxfun(@minus,num_peaks,k');
delta_k = num_peaks - 2;
for i = 1:3
    scatter(peak_separation(i,:),delta_k(i,:) + .1*i,100,C(i,:),'filled');
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
clear peak_separation num_peaks series rates all_p

k = 1;
subset1 = randi(sum(num_cells),20,1);
submyosin = myosins(1:50,subset1);
bg_myosin = nanmean(submyosin,2)';
x = (1:50)*sec_per_frame;

for i = 1:1
    for j = 1:1
        
        mu = [100];
        sigma = 16*ones(1,k);
        A = 10000*i;
        params = cat(1,A,mu,sigma);
        
        noise_size = 0;
        noise = randn(size(x))*noise_size;
        
        % Make the curve-to-fit
        y = synthesize_gaussians(params,x) + noise + bg_myosin;
        
        [p] = iterative_gaussian_fit(y,x,.01,[0;0;10],[Inf;max(x);20],'on');
        
        %     residuals(i,j,:) = y - synthesize_gaussians(p,x);
        %     resnorm(i,j) = sum(residuals(i,j,:).^2);
        
        %         series(i,j,:) = y;
        %         rates(i,j,:) = dy;
        %         all_p{i,j} = p;
        
        if j == 1
            figure
            plot(x,y);
            hold on,plot(x,synthesize_gaussians(p(:,2:end),x),'r-');
            legend('Simulated myosin rate','Pulses fitted','Simulated myosin rate');
            title(['Fitted myosin at center separation ' num2str(16*i) ' sec'])
        end
        
        %         separation = min(diff(sort(mu,'ascend')));
        %         peak_separation(i,j) = separation;
        %         peak_ratio(i,j) = max(A)/min(A);
        %     noise_level(i,j) = noise_size;
        num_peaks(i,j) = size(p,2);
        %         title(['Separation ' num2str(separation), ' sec']);
    end
end





