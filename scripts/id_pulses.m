%ID_PULSES
% Tries to find myosin pulses

folder2load = '/Users/Imagestation/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements/';
msmt2make = {'area','myosin_intensity','vertex-x','vertex-y','identity of neighbors'};

m = load_edge_data(folder2load,msmt2make{:});
areas = extract_msmt_data(m,'area','on');
myosins = extract_msmt_data(m,'myosin intensity','on');
neighborID = extract_msmt_data(m,'identity of neighbors','off');

[num_frames,num_z,num_cells] = size(areas);
%% Generate correlations
% areas = areas(40:end,:,:);
% myosin = myosin(40:end,:,:);
zslice = 2;

areas_sm = smooth2a(squeeze(areas(:,zslice,:)),1,0);
myosins_sm = smooth2a(squeeze(myosins(:,zslice,:)),1,0);

areas_rate = -central_diff_multi(areas_sm,1,1);
myosins_rate = central_diff_multi(myosins_sm);

wt = 20;
correlations = nanxcorr(myosins_rate,areas_rate,wt,1);

%% Get individual correlations
zslice = 1;
cellID = 79;

area_sm = smooth2a(squeeze(areas(:,zslice,cellID)),1,0);
myosin_sm = smooth2a(squeeze(myosins(:,zslice,cellID)),1,0);

area_rate = -central_diff_multi(area_sm,1,1);
myosin_rate = central_diff_multi(myosin_sm,1,1);

wt = 20;
correlation = nanxcorr(area_rate,myosin_rate,wt,1);

%% Plot individual correlations
figure,showsub(@plot,{1:num_frames,area_sm},['Cell area for cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_sm},['Myosin found in cell #' num2str(cellID)],'' ...
    );
figure,showsub(@plot,{1:num_frames,area_rate,'r-'}, ...
    ['Constriction in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_rate,'r-'}, ...
    ['Myosin change in cell #' num2str(cellID)],'' ...
    );

figure,plot(-wt:wt,correlation);
title('Cross correlation between constriction rate and myosin')

%% Interpolate, bg subtract, and fit Gaussians
cellID = randi(82);
myosin_sm = myosins_sm(:,cellID);
myosin_interp = interp_and_truncate_nan(myosin_sm);
x = 1:numel(myosin_interp);
myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});

lb = [0 0 0];
ub = [Inf Inf 20];
gauss_p = iterative_gaussian_fit(myosin_nobg,x,0.1,lb,ub);
figure;
h = plot(synthesize_gaussians(1:59,gauss_p));
hold on,plot(myosin_interp,'r-');
hold on,plot(myosin_nobg,'g-');
legend('Fitted peaks','Original signal','BG subtraction')
title(['Cell #' num2str(cellID)]);
saveas(h,['~/Desktop/Pulse finding/cell_' num2str(cellID)]);

%% Fit Gaussians for all
peaks = zeros(size(myosins_sm));
for i = 1:num_cells
    myosin_sm = myosins_sm(:,i);
    if numel(myosin_sm(~isnan(myosin_sm))) > 1 && any(myosin_sm > 0)
        myosin_interp = interp_and_truncate_nan(myosin_sm);
        x = 1:numel(myosin_interp);
        myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
        
        lb = [0 0 0];
        ub = [Inf Inf 20];
        gauss_p = iterative_gaussian_fit(myosin_nobg,x,0.1,lb,ub);
        pulse_locations = synthesize_gaussians(1:num_frames,gauss_p) > 500;
%         keyboard
        peaks(pulse_locations,i) = 1;
    end
end

%% Plot peaks and the neighbors' peaks

cellID = randi(82);
neighbors = neighborID{10,zslice,cellID};
% plot(peaks(:,center),'k-');
% hold on;
figure
subplot(2,1,1);
plot(peaks(:,cellID));
hold on
p_neighb = sum(peaks(:,neighbors),2)./6;
plot(p_neighb,'r-');
subplot(2,1,2);
pcolor(peaks(:,neighbors)');


%% Plot cell correlation as in time
X = 1000;
Y = 400;
max_corr = nanmax(correlations,[],2);
max_corr = max_corr(:,ones(1,num_frames));
F = draw_measurement_on_cells(m,myosins_rate',X,Y,.19);