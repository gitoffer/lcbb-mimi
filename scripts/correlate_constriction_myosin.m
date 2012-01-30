%CORRELATE_CONSTRICTION_MYOSIN
%
% xies@mit.edu Jan 2012


folder2load = '/Users/Imagestation/Documents/MATLAB/EDGE/DATA_GUI/Adam 100411 mat15/Measurements';
% msmt2make = {'area','myosin_intensity'};

m = load_edge_data(folder2load,msmt2make);
areas = extract_msmt_data(m,'area','on');
myosins = extract_msmt_data(m,'myosin intensity','on');
anisotropys = extract_msmt_data(m,'anisotropy','on');
perimeters = extract_msmt_data(m,'perimeter','on');
orientations = extract_msmt_data(m,'orientation','on');

[num_frames,num_z,num_cells] = size(areas);
%%
% areas = areas(40:end,:,:);
% myosin = myosin(40:end,:,:);
zslice = 6;

areas_sm = smooth2a(squeeze(areas(:,zslice,:)),1,0);
myosins_sm = smooth2a(squeeze(myosins(:,zslice,:)),1,0);
anisotropys_sm = smooth2a(squeeze(anisotropy(:,zslice,:)),1,0);
perimeters_sm = smooth2a(squeeze(perimeters(:,zslice,:)),1,0);
orientations_sm = smooth2a(squeeze(orientations(:,zslice,:)),1,0);

figure,showsublink(@imagesc,{[1 num_frames],[1 num_cells],areas_sm'},'Cell areas','colorbar;', ...
    @imagesc,{[1 num_frames],[1 num_cells],orientations_sm'},'Myosin intensity (clipped)','colorbar' ...
    );

areas_rate = -diff(areas_sm,1,1);
myosins_rate = diff(myosins_sm,1,1);
anisotropys_rate = diff(anisotropy_sm,1,1);
orientations_rate = -diff(orientations_sm,1,1);

figure,showsublink(@imagesc,{[1 num_frames],[1 num_cells],areas_rate'},'Constriciton rate','colorbar;', ...
    @imagesc,{[1 num_frames],[1 num_cells],orientations_rate'},'Myosin rate','colorbar' ...
    );

wt = 20;
correlations = nanxcorr(orientations_rate,areas_rate,wt,1);

mean_corr = nanmean(correlations);
std_corr = nanstd(correlations);
figure,showsub(@imagesc,{[-wt wt],[1 num_cells], correlations},'Cross-correlation per cell','colorbar', ...
    @errorbar,{-wt:wt,mean_corr,std_corr},'Mean cross-correlation','axis on');

%%
zslice = 5;

cellID = 55;
area_sm = smooth2a(squeeze(areas(:,zslice,cellID)),1,0);
myosin_sm = smooth2a(squeeze(myosin(:,zslice,cellID)),1,0);
figure,showsub(@plot,{1:num_frames,area_sm},['Cell area for cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_sm},['Myosin found in cell #' num2str(cellID)],'' ...
    );

area_rate = -diff(area_sm,1,1);
myosin_rate = diff(myosin_sm,1,1);
figure,showsub(@plot,{1:num_frames-1,area_rate},['Constriction in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames-1,myosin_rate},['Myosin change in cell #' num2str(cellID)],'' ...
    );

wt = 20;
correlation = nanxcorr(area_rate,myosin_rate,wt,1);
figure,plot(-wt:wt,correlation);
title('Cross correlation between constriction rate and myosin')