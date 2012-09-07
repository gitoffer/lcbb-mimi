% Domain (time)
sec_per_frame = 6;
x = (0:60)*sec_per_frame;

clear peak_separation num_peaks

% Number of peaks
k = 2:6;

for i = 1:5
    for j = 1:100
        
        % Parameters
        mu = randi(floor(max(x)),[1,k(i)]);
%         mu = [100 100+64];
        sigma = ones(1,k(i)) + 16;
        A = 100+randn(1,k(i))*20;
        params = cat(1,A,mu,sigma);
        
        noise_size = 5*i;
        noise = randn(size(x))*noise_size;
        
        % Make the curve-to-fit
        y = synthesize_gaussians(params,x) + noise;
        
        [p] = version2(y,x,.01,[0 0 10],[Inf max(x) 20]);

%         
%         y_hat = synthesize_gaussians(p,x);
%         
%         plot(x,y);
%         title('Original signal');
%         
%         hold on;
%         plot(x,y_hat,'r-');
%         hold off;
        
        separation = sort(diff(sort(mu)),'ascend');
        peak_separation(i,j) = separation(1);
        num_peaks(i,j) = size(p,2);
        
    end
end

%%

for i = 1:10
    for j = unique(num_peaks(i,:))
        foo = num_peaks(i,:);
        h(i) = draw_circle([peak_separation(i)*10 j*100],numel(foo(foo==j))/3,1000,'--');
        axis equal
        hold on
    end
end

%%


