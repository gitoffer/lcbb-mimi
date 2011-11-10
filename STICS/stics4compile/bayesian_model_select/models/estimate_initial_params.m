function bar = estimate_initial_params(corr,input,stics_opt,pb)

model_name = input.Model;
flat = @(x) x(:);
G000 = max(corr(:)) - min(corr(:));
G_inf = min(corr(:));
xdata = input.xdata;

xf = xdata(1);
x = (1:xf)*stics_opt.um_per_px;
yf = xdata(2);
y = (1:yf)*stics_opt.um_per_px;
t0 = xdata(3);
tf = xdata(4);
t = (t0:tf)*stics_opt.sec_per_frame;
t = t';

switch model_name
    case 'flow_model'
        b0 = zeros(1,4);
        b0(1) = G000;
        b0(2) = G_inf;
        
        %vx
        [~,i] = max(max(corr(:,:,1),[],2));
        [~,j] = max(max(corr(:,:,2),[],2));
        b0(3) = (x(i)-x(j))/(t(2)-t(1));
        %vy
        [~,i] = max(max(corr(:,:,1),[],1));
        [~,j] = max(max(corr(:,:,2),[],1));
        b0(4) = (y(i)-y(j))/(1);
        lb = [0 -Inf -Inf -Inf];
        ub = [Inf Inf Inf Inf];
        
        if pb
            lambda = G000 - max(flat(corr(:,:,2)));
            b0(end+1) = lambda;
        end
        bar{1} = b0;
        bar{2} = lb;
        bar{3} = ub;
        
    case 'diffusion_model'
        b0 = zeros(1,3);
        b0(1) = G000;
        b0(2) = G_inf;
        
        %D
        b0(3) = (G000-max(flat(corr(:,:,2))))/(t(2)-t(1));
        b0(2) = G_inf;
        lb = [0 -Inf 0];
        ub = [Inf Inf Inf];
        
        if pb
            lambda = G000 - max(flat(corr(:,:,2)));
            b0(end+1) = lambda;
        end
        bar{1} = b0;
        bar{2} = lb;
        bar{3} = ub;
        
    case 'mixed_model'
        
        b0 = zeros(1,5);
        b0(1) = G000;
        b0(2) = G_inf;
        %D
        b0(3) = (G000-max(flat(corr(:,:,2))))/(t(2)-t(1));
        %vx
        [~,i] = max(max(corr(:,:,1),[],2));
        [~,j] = max(max(corr(:,:,2),[],2));
        b0(3) = (x(i)-x(j))/(t(2)-t(1));
        %vy
        [~,i] = max(max(corr(:,:,1),[],1));
        [~,j] = max(max(corr(:,:,2),[],1));
        b0(4) = (y(i)-y(j))/(1);
        lb = [0 -Inf 0 -Inf -Inf];
        ub = [Inf Inf Inf Inf Inf];
        
        if pb
            lambda = G000 - max(flat(corr(:,:,2)));
            b0(end+1) = lambda;
        end
        bar{1} = b0;
        bar{2} = lb;
        bar{3} = ub;
        
    case 'noise_model'
        G_inf = mean(corr(:));
        
        b0(1) = G_inf;
        
        bar{1} = b0;
        bar{2} = -Inf;
        bar{3} = Inf;
        
end