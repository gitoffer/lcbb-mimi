options = struct('time_avg','off','local','on','mean_subt','off');
[Xf,Yf] = grid4stics(imcropped,dx,dy,wx,wy);

colorset = varycolor(numel(stics_img));
dR = 10;
Rmax = max(Yf(:));

[C_loc,R] = get_scf4stics(stics_img,Xf,Yf,dR,Rmax,stics_opt,options);
[foo,bar] = meshgrid(R,t*stics_opt.sec_per_frame);
h = pcolor(foo,bar,C_loc);caxis([-1 1]);colorbar;
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/SCF/']);
title(['C(R) with local normalization, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/SCF/coherence_localnorm'],'fig')

figure
set(gca, 'ColorOrder', colorset);
hold all
for i = 1:size(C_loc,1)
    h = plot(R,C_loc(i,:),'Linewidth',1);
end
title(['C(R) with local normalization, mean subtraction ' options.mean_subt])
xlabel('Distance (\mum)')
ylabel('Coherence')
saveas(h,[io.save_name '/SCF/coherence_localnorm_single'],'fig')
% save([io.save_name '/SCF/local_SCF_meansub'],'C_loc','R')

%%
options = struct('time_avg','off','local','off','mean_subt','on');

colorset = varycolor(numel(stics_img));
dR = 10;
Rmax = max(Yf(:));

[C_gl,R] = get_scf4stics(stics_img,Xf,Yf,dR,Rmax,stics_opt,options);
[foo,bar] = meshgrid(R,t*stics_opt.sec_per_frame);
h = pcolor(foo,bar,C_gl);caxis([-1 1]);colorbar;
xlabel('Distance (\mum)')
ylabel('Time (s)')
title(['C(R) with global normalization, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/SCF/coherence_glnorm_meansub'],'fig')

figure
set(gca, 'ColorOrder', colorset);
hold all
for i = 1:size(C_gl,1)
    h = plot(R,C_gl(i,:),'linewidth',1);
end
title(['C(R) with global normalization, mean subtraction ' options.mean_subt])
xlabel('Distance (\mum)')
ylabel('Coherence')
saveas(h,[io.save_name '/SCF/coherence_glnorm_single_meansub'],'fig')

save([io.save_name '/SCF/global_SCF_meansub'],'C_gl','R')