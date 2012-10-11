%%ID_PULSES

in = input;
% in = input_twist;
%% Interpolate, and fit Gaussians for single cells
% cellID = 1;
% cellID = randi(num_cells(2),1) + num_cells(1)
cellID = 54

myosin_sm = myosins(1:end,cellID);
if numel(myosin_sm(~isnan(myosin_sm))) < 20
    error
end
myosin_rate = myosins_rate(1:end,cellID);

% Interpolate
[myosin_interp,I] = interp_and_truncate_nan(myosin_sm);

% Time domain information
% t = time_mat(1:numel(myosin_interp),cellID)';
t = master_time(IDs(cellID).which).aligned_time(I:I+numel(myosin_interp)-1);

lb = [0;t(1);10]; % Lower bounds
ub = [nanmax(myosin_interp);t(end);50]; % Upper bounds
gauss_p = iterative_gaussian_fit(myosin_interp,t,0.01,lb,ub,'on');

% Get the fitted data
fitted_y = synthesize_gaussians(gauss_p,t);

%% Generate plots
n_peaks = size(gauss_p,2)-1
% n_peaks = cell_fits(cellID).num_peaks;
x = master_time(IDs(cellID).which).aligned_time;

figure;

h = subplot(2,1,1);
h1 = plot(x,myosin_sm,'r-');
title(['Myosin time-series in cell #' num2str(cellID)]);
subplot(2,1,2);
h2 = plot(t,myosin_interp,'k-');
hold on,plot(t,lsq_exponential(gauss_p(:,1),t),'k-');
% hold on,plot(t,fitted_y,'r-');

% Plot individual peaks
% figure
C = bone(numel(t)+10);
% C = C(randperm(n_peaks),:);
for i = 1:n_peaks
    hold on
    plot(t,synthesize_gaussians(gauss_p(:,i+1),t),'Color',C(findnearest(gauss_p(2,i+1)+10,t),:));
    %     plot(t,synthesize_gaussians(cell_fits(cellID).params(:,i+1),t),'Color',C(i,:));
end
% hold on,plot(x,cell_fits(:,cellID));
% legend('Myosin rate','Rate rectified',['Fitted peaks (' num2str(n_peaks) ')'])
title(['Detected pulses']);

if strcmpi(in(1).folder2load,input_twist(1).folder2load)
    if IDs(cellID).which == 1, var_name = '006'; else var_name = '022'; end
    saveas(gcf,['~/Desktop/EDGE processed/Twist ' var_name '/detected_pulses/cell_' num2str(IDs(cellID).cellID)],'fig');
    saveas(gcf,['~/Desktop/EDGE processed/Twist ' var_name '/detected_pulses/cell_' num2str(IDs(cellID).cellID)],'epsc');
elseif strcmpi(in(1).folder2load,input(1).folder2load)
    if IDs(cellID).which == 1, var_name = '4'; else var_name = '7'; end
    saveas(gcf,['~/Desktop/EDGE processed/Embryo ' var_name '/detected_pulses/cell_' num2str(IDs(cellID).cellID)],'fig');
    saveas(gcf,['~/Desktop/EDGE processed/Embryo ' var_name '/detected_pulses/cell_' num2str(IDs(cellID).cellID) '.eps'],'epsc');
end
% close all

%% Make movie

figure,clear h

% Gray palette
for i = 1:n_peaks
    ColorOrder(i,:) = C(findnearest(gauss_p(2,i+1)+10,t),:);
end

P = plot_peak_color(gauss_p(:,2:end),x,ColorOrder);

h.vx = vertices_x; h.vy = vertices_y;
h.frames2load = master_time(IDs(cellID).which).frame;
h.sliceID = 4;
h.cellID = cellID;
h.input = in(IDs(cellID).which);
h.channels = {};
% h.channels = {'Membranes','Myosin'};
h.border = 'on';
h.measurement = P;

F = make_cell_img(h);

% Save movie (to appropriate folder)
if strcmpi(in(1).folder2load,input_twist(1).folder2load)
    if IDs(cellID).which == 1, var_name = '006'; else var_name = '022'; end
    movie2avi(F,['~/Desktop/EDGE processed/Twist ' var_name '/cell_movies/cell_' num2str(IDs(cellID).cellID)]);
elseif strcmpi(in(1).folder2load,input(1).folder2load)
    if IDs(cellID).which == 1, var_name = '4'; else var_name = '7'; end
    movie2avi(F,['~/Desktop/EDGE processed/Embryo ' var_name '/cell_movies/cell_' num2str(IDs(cellID).cellID)]);
end

close(gcf)


%% Fit for all cells
opt.alpha = 0.01;
opt.sigma_lb = 10; % Lower bounds
opt.sigma_ub = 50; % Upper bounds
opt.bg = 'on';

[pulse,cell_fits] = fit_gaussian_peaks(myosins,master_time,[-300 1000],IDs,opt);
num_peaks = numel(pulse);
save('~/Desktop/Aligned embryos/Embryo 4+7/detected_pulses','pulse','cell_fit')

