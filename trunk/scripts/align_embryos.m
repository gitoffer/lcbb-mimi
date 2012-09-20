%align_embryos

dt = [input_twist.dt];

figure
color = hsv(num_embryos);
for i = 1:num_embryos
    
    H(i) = shadedErrorBar(time_mat*dt(i),nanmean(myosins(:,c==i),2), ...
        nanstd(myosins(:,c==i),[],2),{'color',color(i,:)},1);
    hold on
end
hold off
legend([H.mainLine],'Embryo 1, 7.4 sec/frame','Embryo 2, 6.7 sec/frame',...
    'mat15, 4.2 sec/frame');
