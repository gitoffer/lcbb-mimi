ID = 4;

time = master_time(pulse(ID).embryo).aligned_time;
center = pulse(ID).center

plotyy(time,myosins_sm(:,pulse(ID).cell),...
    time,areas_sm(:,pulse(ID).cell))
