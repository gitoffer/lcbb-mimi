%align_embryos

num_embryos = 3;
dt = [7.4 5.7 4.2];

figure
color = hsv(num_embryos);
for i = 1:num_embryos
    
    H(i) = shadedErrorBar(time*dt(i),nanmean(myosins(:,c==i),2), ...
        nanstd(myosins(:,c==i),[],2),{'color',color(i,:)},1);
    hold on
end
hold off
legend([H.mainLine],'Embryo 1, 7.4 sec/frame','Embryo 2, 6.7 sec/frame',...
    'mat15, 4.2 sec/frame');
