%align_embryos

num_embryos = 2;
dt = [8 8];

figure
color = hsv(num_embryos);
for i = 1:num_embryos
    
    H(i) = shadedErrorBar(t(:)*dt(i),nanmean(anisotropies(:,c==i),2), ...
        nanstd(anisotropies(:,c==i),[],2),{'color',color(i,:)},1);
    hold on
end
hold off
xlabel('Time (sec)')
legend([H.mainLine],'Embryo 1, 7.4 sec/frame','Embryo 2, 6.7 sec/frame')
