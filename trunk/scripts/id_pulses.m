%%ID_PULSES

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
max_frame = 50; t0 = 0;
peaks = nan(max_frame,num_cells);
binary_peaks = nan(max_frame,num_cells);
myosins_sm_norm = bsxfun(@rdivide,myosins_fuzzy_sm,nanmax(myosins_fuzzy_sm));
myosins_rate_norm = central_diff_multi(myosins_sm_norm,1:num_frames);
clear individual_peaks,num_peaks = 0;
clear peak_locations gauss_parameters
clear peak_cells
clear peak_sizes peak_centers
clear pulse

for i = 1:sum(num_cells)
    
    myosin_sm = myosins_rate(t0+1:t0+max_frame,i);
    
    if numel(myosin_sm(~isnan(myosin_sm) & myosin_sm ~= 0)) > 20 ...
            && any(myosin_sm > 0)
        
        myosin_interp = interp_and_truncate_nan(myosin_sm);
        x = (1:numel(myosin_interp)) + t0;
%         myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
        myosin_nobg = myosin_interp;
        myosin_nobg_rect = myosin_nobg;
        myosin_nobg_rect(myosin_nobg < 0) = 0;
        
        lb = [0 0 0];
        ub = [Inf num_frames 15];
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
        foo = synthesize_gaussians(x,gauss_p);
        if numel(foo) ~= max_frame, foo = [foo, nan(1,max_frame-numel(foo))]; end
        peaks(:,i) = foo;
        gauss_parameters{i} = gauss_p;
        
%         keyboard
        for j = 1:size(gauss_p,2)
            if gauss_p(2,j) > 30
                
                num_peaks = num_peaks + 1;
%                 left = max(fix(gauss_p(2,j) - 3*gauss_p(3,j)),1);
                left = max(fix(gauss_p(2,j) - 5),1);
%                 right = min(fix(gauss_p(2,j) + 3*gauss_p(3,j)),num_frames);
                right = min(fix(gauss_p(2,j) + 10),num_frames);
                x = left:right;
                
%                 if i == 22
%                             keyboard
%                 end
                individual_peaks{num_peaks} = ...
                    synthesize_gaussians(x,gauss_p(:,j));
                peak_locations{num_peaks} = x;
                peak_cells(num_peaks) = i;
                peak_sizes(num_peaks) = gauss_p(1,j);
                peak_centers(num_peaks) = gauss_p(2,j);
                
                pulse(num_peaks).size = gauss_p(1,j);
                pulse(num_peaks).center = gauss_p(2,j);
                pulse(num_peaks).cell = i;
%                 pulse(num_peaks).center = gauss_p(2,j);
                
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


