%%ID_PULSES

%% Interpolate, and fit Gaussians for single cells
% cellID = 1;
% cellID = 51

myosin_sm = myosins(1:end,cellID);
% if numel(myosin_sm(~isnan(myosin_sm))) < 20
%     continue
% end
myosin_rate = myosins_rate(1:end,cellID);

% Interpolate
[myosin_interp,I] = interp_and_truncate_nan(myosin_sm);

% Time domain information
% t = time_mat(1:numel(myosin_interp),cellID)';
t = master_time(IDs(cellID).which).aligned_time(I:I+numel(myosin_interp)-1);

lb = [0;t(1);20]; % Lower bounds
ub = [nanmax(myosin_interp);t(end);50]; % Upper bounds
gauss_p = iterative_gaussian_fit(myosin_interp,t,0.01,lb,ub,'on');

% Get the fitted data
fitted_y = synthesize_gaussians(gauss_p,t);

% Generate plots
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
% C = bone(numel(t)+10);
C = varycolor(n_peaks);
C = C(randperm(n_peaks),:);
for i = 1:n_peaks
    hold on
    plot(t,synthesize_gaussians(gauss_p(:,i+1),t),'Color',C(i,:));
    %     plot(t,synthesize_gaussians(cell_fits(cellID).params(:,i+1),t),'Color',C(i,:));
end
title(['Detected areal pulses']);

%% Make movie

figure,clear h

% Visualize the individual peaks by alternating cyan/yellow colors
P = plot_peak_color(gauss_p(:,2:end),x);

h.vx = vertices_x; h.vy = vertices_y;
h.frames2load = master_time(IDs(cellID).which).frame;
switch IDs(cellID).which
    case 1, h.sliceID = 5;
    case 2, h.sliceID = 6;
    case 3, h.sliceID = 1;
end
h.cellID = cellID;
h.input = in(IDs(cellID).which);
h.channels = {'Membranes','Myosin'};
h.border = 'on';
h.measurement = P;

F = make_cell_img(h);

%% Save movie (to appropriate folder)

if strcmpi(in(1).folder2load,input_twist(1).folder2load)
    if IDs(cellID).which == 1, var_name = '006'; else var_name = '022'; end
    movie2avi(F,['~/Desktop/EDGE processed/Twist ' var_name '/cell_movies/cell_' num2str(IDs(cellID).cellID)]);
elseif strcmpi(in(1).folder2load,input(1).folder2load)
    switch IDs(cellID).which
        case 1, var_name = '4';
        case 2, var_name = '7';
        case 3, var_name = '1';
    end
    movie2avi(F,['~/Desktop/EDGE processed/Embryo ' var_name '/cell_movies/cell_' num2str(IDs(cellID).cellID)]);
end

%% Fit for all cells

opt.alpha = [0.01 0.01 0.01 0.05 0.01 0.01 0.01];

opt.sigma_lb = [15 15 15 15 15 15 15]; % Lower bounds on width (sec)
opt.sigma_ub = [50 50 50 60 50 50 50]; % Upper bounds on width (sec)
opt.left_margin = 5; opt.right_margin = 5; %frames
opt.bg = 'on';

% [pulse,cell_fits] = notifier('3102545005@txt.att.net', ...
%     @fit_gaussian_peaks, myosins,master_time,[-1000 1000],IDs,opt);
% num_peaks = numel(pulse);

[pulse,cell_fits] = fit_gaussian_peaks(myosins,master_time,[-1000 1000],IDs,opt);

% if strcmpi(in(1).folder2load,input(1).folder2load)
% save('~/Desktop/Aligned embryos/WT/detected_pulses_wt_twist_notail','pulse','cell_fits','opt','num_peaks')
% elseif strcmpi(in(1).folder2load,input_twist(1).folder2load)
%     save('~/Desktop/Aligned embryos/twist/detected_pulses_wt_twist','pulse','cell_fits')
% end
