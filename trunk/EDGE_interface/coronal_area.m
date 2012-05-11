
%%
wt = 7;
transition = 25;

%%
area_coronal_corr = nanxcorr(areas_rate,coronal_areas_rate,wt);
[x,y] = meshgrid(-wt:wt,1:num_cells);
showsub( ...
    @pcolor,{x,y,area_coronal_corr},'Dynamic correlation between coronal area v. area','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(area_coronal_corr),nanstd(area_coronal_corr)},'Average correlation','' ...
    );

%% early

area_coronal_corr_early = nanxcorr(areas_rate(1:transition,:),coronal_areas_rate(1:transition,:),wt);
[x,y] = meshgrid(-wt:wt,1:num_cells);
showsub( ...
    @pcolor,{x,y,area_coronal_corr_early},'Dynamic correlation between coronal area v. area','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(area_coronal_corr_early),nanstd(area_coronal_corr_early)},'Average correlation','' ...
    );

%% late

area_coronal_corr_late = nanxcorr(areas_rate(end-transition:end,:),coronal_areas_rate(end-transition:end,:),wt);
[x,y] = meshgrid(-wt:wt,1:num_cells);
showsub( ...
    @pcolor,{x,y,area_coronal_corr_late},'Dynamic correlation between coronal area v. area','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(area_coronal_corr_late),nanstd(area_coronal_corr_late)},'Average correlation','' ...
    );

%%

win = 25;

foci_corona_corr = zeros(num_frames-win-1,num_cells,2*wt+1);

for i = 1:num_frames-win
    foci_corona_corr(i,:,:) = ...
        nanxcorr(areas_rate(i:i+win,:),coronal_areas_rate(i:i+win,:),wt);
end

figure
pcolor(nanmean(foci_corona_corr(:,:,wt:wt+2),3)'),colorbar
axis equal tight, caxis([-1 1]);
title(['Pearson''s correlation between focal area rate and coronal area rate (window ' num2str(win) ')' ])
xlabel('Starting frame)')
ylabel('Cells')

%%
cellID = 61;

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

figure,plot(nanmean(foci_corona_corr(:,cellID,wt:wt+2),3))
