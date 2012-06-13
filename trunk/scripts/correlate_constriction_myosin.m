%CORRELATE_CONSTRICTION_MYOSIN
%
% xies@mit.edu Jan 2012
%% Generate correlations

wt = 10;
correlations = nanxcorr(myosins_rate,areas_rate,wt,1);
[correlations,no_nan_cells] = delete_nan_rows(correlations,2);

%% Plot myosin, area, rates and average correlation
figure,showsublink(@imagesc,{[1 num_frames],[1 num_cells],areas_sm'},'Cell areas','colorbar;', ...
    @imagesc,{[1 num_frames],[1 num_cells],myosins_sm'},'Myosin intensity (clipped)','colorbar' ...
    );

figure,showsublink(@imagesc,{[1 num_frames],[1 num_cells],areas_rate'},'Constriciton rate','colorbar;', ...
    @imagesc,{[1 num_frames],[1 num_cells],myosins_rate'},'Myosin rate','colorbar' ...
    );

mean_corr = nanmean(correlations);
std_corr = nanstd(correlations);
figure,showsub_vert(@imagesc,{([-wt wt])*8,[1 num_cells], correlations},'Cross-correlation per cell','colorbar', ...
    @errorbar,{(-wt:wt)*8,mean_corr,std_corr},'Mean cross-correlation','axis on');

%% Plot individual correlations
zslice = 1;

cellID = 61;
area_sm = smooth2a(squeeze(areas(:,cellID)),1,0);
myosin_sm = smooth2a(squeeze(myosins(:,cellID)),1,0);
area_rate = -central_diff_multi(area_sm,1,1);
area_rate = areas_rate_neg(:,cellID);
myosin_rate = central_diff_multi(myosin_sm,1,1);

h = figure(1);showsub(@plot,{1:num_frames,area_sm},['Cell area for cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,area_rate,'r-'}, ...
    ['Constriction in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_sm},['Myosin found in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_rate,'r-'}, ...
    ['Myosin change in cell #' num2str(cellID)],'' ...
    );
saveas(h,[handle.io.save_dir '/measurements/cells/cell_' num2str(cellID)])

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
signal = correlations;
signal(isnan(signal)) = 0;
max_corr = zeros(1,num_cells);
for i = 1:num_cells
    [p,resnorm,~,flag] = lsqcurvefit(@lsq_gauss1d,[.2 0 2],-wt:wt,signal(i,:),...
        [0 -wt -wt],[1 wt wt]);
    if flag > 0 && resnorm < sum(signal(i,:))/2
        max_corr(i) = p(1);
    end
end

max_corr = max_corr(ones(1,num_frames),:);
F = draw_measurement_on_cells(EDGEstack,max_corr,X,Y,.19);

%%
%%

win = 20;

foci_corona_corr = zeros(num_frames-win-1,num_cells,2*wt+1);

for i = 1:num_frames-win
    foci_corona_corr(i,:,:) = ...
        nanxcorr(areas_rate(i:i+win,:),myosins_rate(i:i+win,:),wt);
end

figure
dynamic_correlation_ma = nanmax(foci_corona_corr(:,:,wt:wt+2),[],3);
pcolor(dynamic_correlation'),colorbar
axis equal tight, caxis([-1 1]);
title(['Pearson''s correlation between myosin rate and coronal area rate (window ' num2str(win) ')' ])
xlabel('Starting frame)')
ylabel('Cells')

