
ID = 55;

nonantime = ~isnan(master_time(pulse(ID).embryo).frame);
time = master_time(pulse(ID).embryo).aligned_time;
time = time(nonantime);

center = pulse(ID).center

plotyy(time,myosins_sm(nonantime,pulse(ID).cell),...
    time,areas_sm(nonantime,pulse(ID).cell))
hold on
plot(cell_fits(pulse(ID).cell).time,cell_fits(pulse(ID).cell).bg,'r-')
