options = struct('time_avg','off','local','off','mean_subt','on');
signal = stics_img;

[Xf,Yf] = grid4stics(imcropped,dx,dy,wx,wy);
dR = 10;
Rmax = max(Yf(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all
for i = 1:16:numel(signal)
    this_vector{1}(:,:,1) = signal{i}(:,:,1);
    this_vector{1}(:,:,2) = zeros(size(this_vector{1}(:,:,1)));
    [C_loc,R] = get_scf4stics(this_vector,Xf,Yf,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/SCF/']);
title(['C(R) with of V_x, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/SCF/global_xcomp'],'fig')

%%
options = struct('time_avg','off','local','off','mean_subt','on');
signal = stics_img;

[Xf,Yf] = grid4stics(imcropped,dx,dy,wx,wy);
dR = 10;
Rmax = max(Yf(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all
for i = 1:16:numel(signal)
    this_vector{1}(:,:,1) = signal{i}(:,:,1);
    this_vector{1}(:,:,2) = zeros(size(this_vector{1}(:,:,1)));
    [C_loc,R] = get_scf4stics(this_vector,Xf,Yf,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/SCF/']);
title(['C(R) of V_x, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/SCF/global_xcomp_means'],'fig')

%%
options = struct('time_avg','off','local','off','mean_subt','on');
signal = stics_img;

[Xf,Yf] = grid4stics(imcropped,dx,dy,wx,wy);
dR = 10;
Rmax = max(Yf(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all
for i = 1:16:numel(signal)
    this_vector{1}(:,:,2) = signal{i}(:,:,2);
    this_vector{1}(:,:,1) = zeros(size(this_vector{1}(:,:,2)));
    [C_loc,R] = get_scf4stics(this_vector,Xf,Yf,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/SCF/']);
title(['C(R) with of V_y, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/SCF/global_ycomp'],'fig')

%%
options = struct('time_avg','off','local','off','mean_subt','on');
signal = stics_img;

[Xf,Yf] = grid4stics(imcropped,dx,dy,wx,wy);
dR = 10;
Rmax = max(Yf(:));

colorset = jet(floor(numel(signal)/16));
set(gca, 'colororder', colorset);
hold all
for i = 1:16:numel(signal)
    this_vector{1}(:,:,2) = signal{i}(:,:,2);
    this_vector{1}(:,:,1) = zeros(size(this_vector{1}(:,:,2)));
    [C_loc,R] = get_scf4stics(this_vector,Xf,Yf,dR,Rmax,stics_opt,options);
    h = plot(R,C_loc);caxis([0 numel(stics_img)]);colorbar;
end
xlabel('Distance (\mum)')
ylabel('Time (s)')
mkdir([io.save_name '/SCF/']);
title(['C(R) of V_y, mean subtraction ' options.mean_subt])
saveas(h,[io.save_name '/SCF/global_ycomp_means'],'fig')
