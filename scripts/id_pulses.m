%%ID_PULSES

%% Generate correlations
% areas = areas(40:end,:,:);
% myosin = myosin(40:end,:,:);

wt = 10;
correlations = nanxcorr(myosins_rate,areas_rate,wt,1);
figure,pcolor(correlations)
figure,errorbar(-wt:wt,nanmean(correlations,1),nanstd(correlations,1,1));

%% Get individual correlations
cellID = 80;

area_sm = smooth2a(squeeze(areas(:,cellID)),1,0);
myosin_sm = smooth2a(squeeze(myosins(:,cellID)),1,0);

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
cellID = 20;

myosin_sm = myosins_sm(1:30,cellID);
myosin_rate = myosins_rate(1:30,cellID);
myosin_interp = interp_and_truncate_nan(myosin_rate);
x = 1:numel(myosin_interp);
% myosin_nobg = myosin_interp;
myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
myosin_nobg_rect = myosin_nobg;
myosin_nobg_rect(myosin_nobg < 0) = 0;

lb = [0 0 0];
ub = [Inf num_frames 20];
gauss_p = iterative_gaussian_fit(myosin_nobg_rect,x,0.1,lb,ub);

% figure;
subplot(2,1,1)
h1 = plot(myosin_sm,'r-');
hold on,plot(myosin_rate,'k-');
hold on,plot(myosin_nobg_rect,'g-');
hold on,plot(synthesize_gaussians(1:30,gauss_p));
legend('Original myosin signal','Myosin rate','Rate rectified','Fitted peaks')
title(['Myosin intensity in cell #' num2str(cellID)]);
subplot(2,1,2);
plotyy(1:30,areas_rate(1:30,cellID),1:30,areas_sm(1:30,cellID))
legend('Constriction rate','Area')
saveas(h1,['~/Desktop/EDGE Processed/Embryo 4/peak_gauss/cells/cell_' num2str(cellID)]);

%% Fit Gaussians for all
peaks = nan(30,num_cells);
binary_peaks = nan(30,num_cells);
myosins_sm_norm = bsxfun(@rdivide,myosins_fuzzy_sm,nanmax(myosins_fuzzy_sm));
myosins_rate_norm = central_diff_multi(myosins_sm_norm,1:num_frames);
clear individual_peaks, num_peaks = 0;
clear peak_locations
clear peak_cells
clear peak_sizes

for i = 1:num_cells
    
    myosin_sm = myosins_rate_norm(1:30,i);
    if numel(myosin_sm(~isnan(myosin_sm) & myosin_sm ~= 0)) > 20 ...
            && any(myosin_sm > 0)
        myosin_interp = interp_and_truncate_nan(myosin_sm);
        x = 1:numel(myosin_interp);
        %         myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
        myosin_nobg = myosin_interp;
        myosin_nobg_rect = myosin_nobg;
        myosin_nobg_rect(myosin_nobg < 0) = 0;
        
        lb = [0 0 0];
        ub = [Inf num_frames 20];
        gauss_p = iterative_gaussian_fit(myosin_nobg_rect,x,0.1,lb,ub);
        %         left = max(fix(gauss_p(2,:)) - fix(gauss_p(3,:)),1);
        %         right = min(fix(gauss_p(2,:)) + fix(gauss_p(3,:)),num_frames);
        % %         if i == 61
        % %             keyboard
        % %         end
        %         for j = 1:numel(left)
        %             %             keyboard
        %             peaks(left(j):right(j),i) = 1;
        %         end
        %         keyboard
        foo = synthesize_gaussians(x,gauss_p);
        if numel(foo) ~= 30, foo = [foo, nan(1,30-numel(foo))]; end
        peaks(:,i) = foo;
        gauss_parameters{i} = gauss_p;
        
        for j = 1:size(gauss_p,2)
            if gauss_p(2,j) <= 30
                
                num_peaks = num_peaks + 1;
%                 left = max(fix(gauss_p(2,j) - 3*gauss_p(3,j)),1);
                left = max(fix(gauss_p(2,j) - 5),1);
%                 right = min(fix(gauss_p(2,j) + 3*gauss_p(3,j)),num_frames);
                right = min(fix(gauss_p(2,j) + 5),num_frames);
                x = left:right;
                
%                 if i == 22
%                             keyboard
%                 end
                individual_peaks{num_peaks} = ...
                    synthesize_gaussians(x,gauss_p(:,j));
                peak_locations{num_peaks} = x;
                peak_cells(num_peaks) = i;
                peak_sizes(num_peaks) = gauss_p(1,j);
                
            end
        end
    end
end

%%

for i = 1:num_cells
    this_cell = peaks(:,i);
    binary_peaks(:,i) = otsu(this_cell);
end

%% Plot peaks and the neighbors' peaks

cellID = 61;
neighbor_peak_hand = neighbor_msmt(peaks_hand,neighborID);
figure
subplot(2,1,1);
plot(peaks_hand(:,cellID));
hold on
p_neighb = sum(neighbor_peak_hand{cellID},2)/size(neighbor_peak_hand{cellID},2);
plot(p_neighb,'r-');
subplot(2,1,2);
pcolor(neighbor_peak_hand{cellID}');

%% Try to correlate self peaks and neighbor peaks?

wt = 7;
neighbor_peak_hand = neighbor_msmt(peaks_hand,neighborID);
peaks_corr = nan(num_cells,2*wt+1);

for cellID = 1:num_cells
    
    if any(neighbor_peak_hand{cellID} ~= 0)
        
        p_neighb = sum(neighbor_peak_hand{cellID},2)/size(neighbor_peak_hand{cellID},2);
        
        peaks_corr(cellID,:) = nanxcorr(peaks_hand(:,cellID),p_neighb,wt);
        
    end
end
figure,pcolor(-wt:wt,1:num_cells,peaks_corr),colorbar

%% Posterior probability?

p_neighb_me = nan(num_cells,10);
coupling = zeros(num_cells);

for cellID = 1:num_cells
    
    if any(neighbor_peak_hand{cellID} ~= 0)
        for j = 1:numel(neighborID{1,cellID})
            %         p_neighb = sum(neighbor_peak_hand{cellID},2)/size(neighbor_peak_hand{cellID},2);
            %         p_neighb = sum(any(neighbor_peak_hand{cellID},2))/num_frames;
            p_me = sum(peaks_hand(:,cellID))/num_frames;
            p_joint = sum(neighbor_peak_hand{cellID}(:,j) & peaks_hand(:,cellID))/num_frames;
            p_neighb_me(cellID,j) = p_joint/p_me;
            my_neighb = neighborID{1,cellID};
            coupling(cellID,my_neighb(j)) = p_joint/p_me;
        end
    end
    
end

plot(p_neighb_me,'b*')
figure,pcolor(coupling)


