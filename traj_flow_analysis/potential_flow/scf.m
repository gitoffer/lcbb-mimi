options = struct('time_avg','off','local','on','mean_subt','on');

colorset = varycolor(136);
dR = 10;
Rmax = 112;

[C_loc,R] = get_scf4stics(stics_img,Xf,Yf,dR,Rmax,o,options);
[foo,bar] = meshgrid(R,1:size(C_loc,1));
h = pcolor(foo,bar,C_loc);caxis([-1 1]);colorbar;
xlabel('Distance (\mum)')
ylabel('Time (s)')
title('C(R) with local normalization, mean subtraction')
saveas(h,[io.save_name '/SCF/coherence_localnorm_msub'],'fig')

figure
set(gca, 'ColorOrder', colorset);
hold all
for i = 1:size(C_loc,1)
    h = plot(R,C_loc(i,:),'Linewidth',1);
end
title('C(R) with local normalization, mean subtraction')
xlabel('Distance (\mum)')
ylabel('Coherence')
saveas(h,[io.save_name '/SCF/coherence_localnorm_single_msub'],'fig')
save([io.save_name '/SCF/local_SCF'],'C_loc','R')

%%
options = struct('time_avg','off','local','off','mean_subt','on');

colorset = varycolor(136);
dR = 10;
Rmax = 112;

[C_gl,R] = get_scf4stics(stics_img,Xf,Yf,dR,Rmax,o,options);
[foo,bar] = meshgrid(R,1:size(C_gl,1));
h = pcolor(foo,bar,C_gl);caxis([-1 1]);colorbar;
xlabel('Distance (\mum)')
ylabel('Time (s)')
title('C(R) with global normalization')
saveas(h,[io.save_name '/SCF/_coherence_glnorm_msub'],'fig')

figure
set(gca, 'ColorOrder', colorset);
hold all
for i = 1:size(C_gl,1)
    h = plot(R,C_gl(i,:),'linewidth',1);
end
title('C(R) with global normalization')
xlabel('Distance (\mum)')
ylabel('Coherence')
saveas(h,[io.save_name '/SCF/coherence_glnorm_single_msub'],'fig')

save([io.save_name '/SCF/global_SCF'],'C_gl','R')