%CORRELATE_CONSTRICTION_MYOSIN
%
% xies@mit.edu Jan 2012

folder2load = '/Users/Imagestation/Documents/MATLAB/EDGE/DATA_GUI/slice_2color_013012_7/Measurements/';
msmt2make = {'area','myosin_intensity','vertex-x','vertex-y'};

m = load_edge_data(folder2load,msmt2make);
areas = extract_msmt_data(m,'area','on');
myosins = extract_msmt_data(m,'myosin intensity','on');
% anisotropys = extract_msmt_data(m,'anisotropy','on');
% perimeters = extract_msmt_data(m,'perimeter','on');
% orientations = extract_msmt_data(m,'orientation','on');

[num_frames,num_z,num_cells] = size(areas);
%% Generate correlations
% areas = areas(40:end,:,:);
% myosin = myosin(40:end,:,:);
zslice = 3;

areas_sm = smooth2a(squeeze(areas(:,zslice,:)),1,0);
myosins_sm = smooth2a(squeeze(myosins(:,zslice,:)),1,0);
% anisotropy_sm = smooth2a(squeeze(anisotropys(:,zslice,:)),1,0);
% perimeters_sm = smooth2a(squeeze(perimeters(:,zslice,:)),1,0);
% orientations_sm = smooth2a(squeeze(orientations(:,zslice,:)),1,0);

areas_rate = -central_diff_multi(areas_sm,1,1);
myosins_rate = central_diff_multi(myosins_sm);
% anisotropys_rate = central_diff(anisotropy_sm);
% orientations_rate = central_diff(orientations_sm);

wt = 20;
correlations = nanxcorr(myosins_rate,areas_rate,wt,1);

%% Plot myosin, area, rates and average correlation
figure,showsublink(@imagesc,{[1 num_frames],[1 num_cells],areas_sm'},'Cell areas','colorbar;', ...
    @imagesc,{[1 num_frames],[1 num_cells],myosins_sm'},'Myosin intensity (clipped)','colorbar' ...
    );

figure,showsublink(@imagesc,{[1 num_frames],[1 num_cells],areas_rate'},'Constriciton rate','colorbar;', ...
    @imagesc,{[1 num_frames],[1 num_cells],myosins_rate'},'Myosin rate','colorbar' ...
    );

mean_corr = nanmean(correlations);
std_corr = nanstd(correlations);
figure,showsub(@imagesc,{[-wt wt],[1 num_cells], correlations},'Cross-correlation per cell','colorbar', ...
    @errorbar,{-wt:wt,mean_corr,std_corr},'Mean cross-correlation','axis on');

%% Plot individual correlations
zslice = 2;

cellID = 72;
area_sm = smooth2a(squeeze(areas(:,zslice,cellID)),2,0);
myosin_sm = smooth2a(squeeze(myosins(:,zslice,cellID)),1,0);
figure,showsub(@plot,{1:num_frames,area_sm},['Cell area for cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_sm},['Myosin found in cell #' num2str(cellID)],'' ...
    );

area_rate = -central_diff_multi(area_sm,1,1);
myosin_rate = central_diff_multi(myosin_sm,1,1);
figure,showsub(@plot,{1:num_frames,area_rate,'r-'}, ...
    ['Constriction in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_rate,'r-'}, ...
    ['Myosin change in cell #' num2str(cellID)],'' ...
    );

wt = 20;
correlation = nanxcorr(area_rate,myosin_rate,wt,1);
figure,plot(-wt:wt,correlation);
title('Cross correlation between constriction rate and myosin')

%% Interpolate NaNs and truncate NaNs
myosin_interp = interp_and_truncate_nan(myosin_sm);

%% Plot correlations individually
cellID = 72;
center = plot_corr_myo_area(areas,myosins,6);
n1 = plot_corr_myo_area(areas,myosins,5);

%% Plot cell correlation as in time
X = 1000;
Y = 400;
max_corr = nanmax(correlations,[],2);
max_corr = max_corr(:,ones(1,num_frames));
F = draw_measurement_on_cells(m,myosins_rate',X,Y,.19);