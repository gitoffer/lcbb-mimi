function correlation = plot_corr_myo_area(areas,myosins,zslice,cellID)

num_frames = size(areas,1);
area_sm = smooth2a(squeeze(areas(:,zslice,cellID)),2,0);
myosin_sm = smooth2a(squeeze(myosins(:,zslice,cellID)),2,0);
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