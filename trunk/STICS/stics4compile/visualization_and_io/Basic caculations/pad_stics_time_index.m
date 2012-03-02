function I = pad_stics_time_index(o)

wt = o.wt;
dt = o.dt;

tbegin = max(ceil(dt/2),ceil(wt/2));
tend = (o.crop(5)-o.crop(6)+1) - max(ceil(dt/2),ceil(wt/2));
t = tbegin : dt : tend;

I = 1:numel(t);
j = 1:t(end) + floor(wt/2);
I_left = I(ones(1,floor(wt/2)-1));
I = [I_left I];
I_right = I(ones(1,numel(j) - numel(I))*end);
I = [I I_right];
