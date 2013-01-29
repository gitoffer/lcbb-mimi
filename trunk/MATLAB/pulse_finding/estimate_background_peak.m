function [p,lb,ub] = estimate_background_peak(data,handle)

switch func2str(handle.background_function)
    case 'lsq_linear'
        
        window = 10;
        
        high = nanmean(data(end-window:end));
        low = nanmean(data(1:window+1));
        
        p(1) = (high - low)/numel(data);
        p(2) = low;
        
        lb(1) = -max(data);
        lb(2) = -max(data);
        
        ub(1) = max(data)/numel(data);
        ub(2) = max(data);
    case 'lsq_gauss1d'
        
        high = max(data(:));
        mu = numel(data);
        sigma = 20;
        p = [high mu sigma];
        lb = [0 0 0];
        ub = inf(1,3);
        
    case 'lsq_linear_rect'
        
        window = 5;
        
        I = find(data>0,1,'first');
        high = nanmean(data(end-window:end));
        p(1) = high/(numel(data) - I);
        p(2) = -p(1)*I;
        
        lb = [-max(data) -max(data)];
        ub = [max(data)/(numel(data)-I) max(data)];
        
    otherwise
        error('Unsupported function');
        
end