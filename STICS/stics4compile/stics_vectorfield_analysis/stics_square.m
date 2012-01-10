function [signal,X,Y] = stics_square(stics_img,Xf,Yf)

signal = stics_img;
t = numel(signal);
[n,m,~] = size(signal{1});

if n ~= m
    if n > m
        center = ceil(n/2);
        left = center - ceil(m/2);
        right = left + m -1;
        for i = 1:t
            this_v = signal{i};
            signal{i} = this_v(left:right,:,:);
        end
        X = Xf(left:right,:);
        Y = Yf(left:right,:);
    else
        center = ceil(m/2);
        left = center - ceil(n/2);
        right = left + n -1;
        for i = 1:t
            this_v = signal{i};
            signal{i} = this_v(:,left:right,:);
        end
        X = Xf(:,left:right);
        Y = Yf(:,left:right);
    end
end