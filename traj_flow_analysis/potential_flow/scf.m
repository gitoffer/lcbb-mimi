options = {'off','on','off'};

colorset = varycolor(136);

[C_loc,R] = get_scf4stics(stics_img,Xf2,Yf2,o,options);
[foo,bar] = meshgrid(R,1:size(C_loc,1));
h = pcolor(foo,bar,C_loc);caxis([-1 1]);colorbar;
xlabel('Distance (\mum)')
ylabel('Time (s)')
title('C(R) with local normalization')
saveas(h,[io.sticsSaveName '/SCF/_coherence_localnorm_half'],'fig')

figure
set(gca, 'ColorOrder', colorset);
hold all
for i = 1:size(C_loc,1)
    h = plot(R,C_loc(i,:),'Linewidth',1);
end
xlabel('Distance (\mum)')
ylabel('Coherence')
saveas(h,[io.sticsSaveName '/SCF/_coherence_localnorm_single_half'],'fig')
save([io.sticsSaveName '/SCF/local_SCF_half'],'C_loc','R')

%%
options = {'off','off','off'};

colorset = varycolor(136);
[C_gl,R] = get_scf4stics(stics_img,Xf2,Yf2,o,options);
[foo,bar] = meshgrid(R,1:size(C_gl,1));
h = pcolor(foo,bar,C_gl);caxis([-1 1]);colorbar;
xlabel('Distance (\mum)')
ylabel('Time (s)')
title('C(R) with global normalization')
saveas(h,[io.sticsSaveName '/SCF/_coherence_glnorm_half'],'fig')

figure
set(gca, 'ColorOrder', colorset);
hold all
for i = 1:size(C_gl,1)
    h = plot(R,C_gl(i,:),'linewidth',1);
end
xlabel('Distance (\mum)')
ylabel('Coherence')
saveas(h,[io.sticsSaveName '/SCF/_coherence_glnorm_single_half'],'fig')

save([io.sticsSaveName '/SCF/global_SCF_half'],'C_gl','R')