
crop = struct('x0',1,'xf',751,'y0',1,'yf',100); % CROP information
[stics_cropped,Xfc,Yfc] = stics_crop(stics_img,Xf,Yf,crop);

%Make STICS output square
[signal,X,Y] = stics_square(stics_cropped,Xfc,Yfc);

%%
options = struct('time_avg','off','local','off','mean_subt','off');

dR = 10;
Rmax = max(Y(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all

for i = 1:16:numel(signal)
    this_vector{1}(:,:,1) = signal{i}(:,:,1);
    this_vector{1}(:,:,2) = zeros(size(this_vector{1}(:,:,1)));
    [C_loc,R] = get_scf4stics(this_vector,X,Y,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/Half embryos for SCF/']);
title(['C(R) with of V_x, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/Half embryos for SCF/global_xcomp'],'fig')

%%
options = struct('time_avg','off','local','off','mean_subt','on');

dR = 10;
Rmax = max(Y(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all
for i = 1:16:numel(signal)
    this_vector{1}(:,:,1) = signal{i}(:,:,1);
    this_vector{1}(:,:,2) = zeros(size(this_vector{1}(:,:,1)));
    [C_loc,R] = get_scf4stics(this_vector,X,Y,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/Half embryos for SCF/']);
title(['C(R) of V_x, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/Half embryos for SCF/global_xcomp_means'],'fig')

%%
options = struct('time_avg','off','local','off','mean_subt','off');

dR = 10;
Rmax = max(Y(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all
for i = 1:16:numel(signal)
    this_vector{1}(:,:,2) = signal{i}(:,:,2);
    this_vector{1}(:,:,1) = zeros(size(this_vector{1}(:,:,2)));
    [C_loc,R] = get_scf4stics(this_vector,X,Y,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/Half embryos for SCF/']);
title(['C(R) with of V_y, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/Half embryos for SCF/global_ycomp'],'fig')

%%
options = struct('time_avg','off','local','off','mean_subt','on');

dR = 10;
Rmax = max(Y(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all
for i = 1:16:numel(signal)
    this_vector{1}(:,:,2) = signal{i}(:,:,2);
    this_vector{1}(:,:,1) = zeros(size(this_vector{1}(:,:,2)));
    [C_loc,R] = get_scf4stics(this_vector,X,Y,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/Half embryos for SCF/']);
title(['C(R) of V_y, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/Half embryos for SCF/global_ycomp_means'],'fig')
