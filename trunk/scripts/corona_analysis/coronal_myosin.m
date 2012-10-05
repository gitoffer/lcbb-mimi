%% MYOSIN

wt = 7;
transition = 30;

%%
myosin_coronal_corr = nanxcorr(myosins_rate,coronal_masked_mr,wt);
[myosin_coronal_corr,cells2plot] = delete_nan_rows(myosin_coronal_corr,1);
[x,y] = meshgrid((-wt:wt)*8,1:numel(cells2plot));
pcolor(x,y,myosin_coronal_corr),shading flat
figure
showsub( ...
    @pcolor,{x,y,myosin_coronal_corr},'Dynamic correlation between coronal myosin v. myosin','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(myosin_coronal_corr),nanstd(myosin_coronal_corr)},'Average correlation','' ...
    );

%% early

myosin_coronal_corr_early = nanxcorr(myosins_rate(1:30,:),coronal_myosins_rate(1:30,:),wt);
[myosin_coronal_corr_early,cells2plot] = delete_nan_rows(myosin_coronal_corr_early,1);
[x,y] = meshgrid((-wt:wt)*8,1:numel(cells2plot));
figure
pcolor(x,y,myosin_coronal_corr_early)
colorbar
shading flat
% title('Time-resolved correlation between dA_{cor}/dt and dA_{foc}/dt');
% xlabel('Time shift (frames)'),ylabel('Cells');

% shading flat
figure
showsub( ...
    @pcolor,{x,y,myosin_coronal_corr_early},'Dynamic correlation between coronal myosin v. myosin','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(myosin_coronal_corr_early),nanstd(area_coronal_corr_early)},'Average correlation','' ...
    );

%% late

myosin_coronal_corr_late = nanxcorr(myosins_rate(31:end,:),coronal_myosins_rate(31:end,:),wt);
[myosin_coronal_corr_late,cells2plot] = delete_nan_rows(myosin_coronal_corr_late,1);
[x,y] = meshgrid((-wt:wt)*8,1:numel(cells2plot));
figure
pcolor(x,y,myosin_coronal_corr_late),colorbar
shading flat
% title('Time-resolved correlation between dA_{cor}/dt and dA_{foc}/dt in late stage');
figure
showsub( ...
    @pcolor,{x,y,myosin_coronal_corr_late},'Dynamic correlation between coronal myosin v. myosin','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(myosin_coronal_corr_late),nanstd(myosin_coronal_corr_late)},'Average correlation','' ...
    );

%%

win = 30;

foci_corona_corr = zeros(num_frames-win-1,num_cells,2*wt+1);

for i = 1:num_frames-win
    foci_corona_corr(i,:,:) = ...
        nanxcorr(areas_rate(i:i+win,:),coronal_areas_rate(i:i+win,:),wt);
end

figure
signal = nanmean(foci_corona_corr(:,:,wt:wt+2),3);
[signal2,cells2plot] = delete_nan_rows(signal,2);
pcolor(signal2'),colorbar
shading flat
axis equal tight, caxis([-1 1]);
% title(['Pearson''s correlation between focal area rate and coronal area rate (window ' num2str(win) ')' ])
% xlabel('Starting frame)')
% ylabel('Cells')

%%
cellID = 57;

figure
plot(coronal_areas_sm(:,cellID)/5);hold on;
plot(areas_sm(:,cellID),'r-')
legend('Coronal area','Focal area'),xlabel('Time (frames)'),ylabel('Area (\mum^2)')

figure,plot(coronal_areas_rate(:,cellID),'g-'),hold on,plot(areas_rate(:,cellID),'k-');
legend('Coronal rate','Focal rate'),xlabel('Time (frame)'),ylabel('Area/time (\mum^2/sec)')

figure,
plot(-wt:wt,area_coronal_corr_early(cellID,:));

figure,
plot(-wt:wt,area_coronal_corr_late(cellID,:));

figure,plot(signal(:,cellID))
