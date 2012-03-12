function [p,lb,ub] = estimate_initial_peaks(data,m)

[heights,locations] = extrema(data);
Amax = sum(data);
xmin = 0;
xmax = numel(data);

p = zeros(1,3*m);
lb = p;
ub = p;

for i = 1:m
    if numel(heights) < i
        foo = randi(numel(data));
        p(3*(i-1)+2) = data(foo);
        p(3*(i-1)+2) = foo;
        p(3*(i-1)+3) = var(data);
    else
        p(3*(i-1)+1) = heights(i);
        p(3*(i-1)+2) = locations(i);
        p(3*(i-1)+3) = var(data);
    end
    
    lb(3*(i-1)+1) = 0;
    lb(3*(i-1)+2) = xmin;
    lb(3*(i-1)+3) = 1;
    
    ub(3*(i-1)+1) = Amax;
    ub(3*(i-1)+2) = xmax;
    ub(3*(i-1)+3) = xmax;
    
end

end