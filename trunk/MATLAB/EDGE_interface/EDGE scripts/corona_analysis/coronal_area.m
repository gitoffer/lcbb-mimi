
%%
wt = 7;
transition = 30;

%%
area_coronal_corr = nanxcorr(areas_rate,coronal_areas_rate,wt);
[area_coronal_corr2,cells2plot] = delete_nan_rows(area_coronal_corr,1);
[x,y] = meshgrid((-wt:wt)*8,1:numel(cells2plot));
pcolor(x,y,area_coronal_corr2),shading flat;colorbar
figure
showsub( ...
    @pcolor,{x,y,area_coronal_corr2},'Dynamic correlation between coronal area v. area','colorbar,axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(area_coronal_corr2),nanstd(area_coronal_corr2)},'Average correlation','' ...
    );

%% early

area_coronal_corr_early = nanxcorr(areas_rate(1:30,:),coronal_areas_rate(1:30,:),wt);
[area_coronal_corr_early2,cells2plot] = delete_nan_rows(area_coronal_corr_early,1);
[x,y] = meshgrid((-wt:wt)*8,1:numel(cells2plot));
figure
pcolor(x,y,area_coronal_corr_early2)
colorbar
shading flat
% title('Time-resolved correlation between dA_{cor}/dt and dA_{foc}/dt');
% xlabel('Time shift (frames)'),ylabel('Cells');

% shading flat
figure
showsub( ...
    @pcolor,{x,y,area_coronal_corr_early2},'Dynamic correlation between coronal area v. area','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(area_coronal_corr_early2),nanstd(area_coronal_corr_early2)},'Average correlation','' ...
    );

%% late

area_coronal_corr_late = nanxcorr(areas_rate(31:end,:),coronal_areas_rate(31:end,:),wt);
[area_coronal_corr_late2,cells2plot] = delete_nan_rows(area_coronal_corr_late,1);
[x,y] = meshgrid((-wt:wt)*8,1:numel(cells2plot));
figure
pcolor(x,y,area_coronal_corr_late2),colorbar
shading flat
% title('Time-resolved correlation between dA_{cor}/dt and dA_{foc}/dt in late stage');
figure
showsub( ...
    @pcolor,{x,y,area_coronal_corr_late2},'Dynamic correlation between coronal area v. area','axis equal tight;colorbar;', ...
    @errorbar,{-wt:wt,nanmean(area_coronal_corr_late2),nanstd(area_coronal_corr_late2)},'Average correlation','' ...
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

